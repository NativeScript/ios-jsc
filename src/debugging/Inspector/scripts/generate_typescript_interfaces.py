#!/usr/bin/env python

import os.path
from codegen import *
import json

_PRIMITIVE_TO_TS_NAME_MAP = {
    'integer': 'number',
    'object': 'Object'
}

def ts_name_for_primitive_type1(_type):
    ts_name = _PRIMITIVE_TO_TS_NAME_MAP.get(_type.raw_name())
    if ts_name:
        return ts_name
    return _type.raw_name()

def ts_name_for_primitive_type(domain, parameter_type):
    type_raw_name = ''

    if isinstance(parameter_type, ObjectType) or isinstance(parameter_type, AliasedType):
        if parameter_type.type_domain() == domain:
            type_raw_name = parameter_type.raw_name()
        else:
            parameter_args = {
                'domain': parameter_type.type_domain().domain_name,
                'type': parameter_type.raw_name()
            }
            type_raw_name = '%(domain)sDomain.%(type)s' % parameter_args
    elif isinstance(parameter_type, ArrayType):
        type_raw_name = '%s[]' % ts_name_for_primitive_type(domain, parameter_type.element_type)
    elif isinstance(parameter_type, EnumType):
        #implement me
        type_raw_name = 'void' 
    elif isinstance(parameter_type, PrimitiveType): 
        raw_name = parameter_type.raw_name()   
        ts_name = _PRIMITIVE_TO_TS_NAME_MAP.get(raw_name)
        type_raw_name = ts_name if ts_name else raw_name

    return type_raw_name

def load_specification(protocol, filepath, isSupplemental=False):
    try:
        with open(filepath, "r") as input_file:
            parsed_json = json.load(input_file)
            protocol.parse_specification(parsed_json, isSupplemental)
    except ValueError as e:
        raise Exception("Error parsing valid JSON in file: " + filepath)

protocol = models.Protocol("JavaScriptCore")

load_specification(protocol, "/Users/koeva/work/temp/CombinedDomains.json");

protocol.resolve_types()

# reuse me
# A writer that only updates file if it actually changed.
class IncrementalFileWriter:
    def __init__(self, filepath, force_output):
        self._filepath = filepath
        self._output = ""
        self.force_output = force_output

    def write(self, text):
        self._output += text

    def close(self):
        text_changed = True
        self._output = self._output.rstrip() + "\n"

        try:
            if self.force_output:
                raise

            read_file = open(self._filepath, "r")
            old_text = read_file.read()
            read_file.close()
            text_changed = old_text != self._output
        except:
            # Ignore, just overwrite by default
            pass

        if text_changed or self.force_output:
            out_file = open(self._filepath, "w")
            out_file.write(self._output)
            out_file.close()

class TypeScriptInterfaceGenerator(Generator):
    def __init__(self, model):
        Generator.__init__(self, model, "")
    
    def output_filename(self):
        return "InspectorBackendCommands.ts"

    def domains_to_generate(self):
        def should_generate_domain(domain):
            # domain_enum_types = filter(lambda declaration: isinstance(declaration.type, EnumType), domain.type_declarations)
            # return len(domain.commands) > 0 or len(domain.events) > 0 or len(domain_enum_types) > 0
            return True

        return filter(should_generate_domain, Generator.domains_to_generate(self))

    def generate_output(self):
        sections = []
        sections.append('''interface FrontendDispatcher { 
    dispatch(message: string): void; 
}
        ''')
        sections.append('''class Dispatcher {
    dispatch(message: string) {
        var json = JSON.parse(message);
        var methodName = json.method;

        if (this[methodName] != null) {
            this[methodName].apply(this, []); // arguments ?
        } else {
            throw new Error("No Such method");
        }
    }
}''')
        sections.extend(map(self.generate_domain, self.domains_to_generate()))
        return "\n\n".join(sections)

    def generate_domain(self, domain):
        lines = []
        args = {
            'domain': domain.domain_name
        }

        lines.append('// %(domain)s.' % args)
        lines.append('namespace %(domain)sDomain {' % args)

        lines.extend(self.generate_domain_type_declarations(domain))
        
        lines.append("interface %(domain)sDomainDispatcher { " % args);
        lines.extend(self.generate_domain_commands(domain))
        lines.append('}')

        lines.append("class %(domain)sFrontend { " % args);
        lines.append('\tconstructor(private _frontendDispatcher: FrontendDispatcher) { \n\t}')
        lines.extend(self.generate_domain_events(domain))
        lines.append('}')

        lines.append('}')
        return "\n".join(lines)

    def generate_domain_type_declarations(self, domain):
        lines = []
        primitive_declarations = filter(lambda decl: isinstance(decl.type, AliasedType), domain.type_declarations)
        object_declarations = filter(lambda decl: isinstance(decl.type, ObjectType), domain.type_declarations)

        for primitive_declaration in primitive_declarations:
            type_def_args = { 
                'name': primitive_declaration.type_name,
                'type': ts_name_for_primitive_type(domain, primitive_declaration.type.aliased_type),
                'description': primitive_declaration.description if primitive_declaration.description else 'No description'  
            }
            lines.append('export type %(name)s = %(type)s // %(description)s' % type_def_args)

        lines.append('')

        for declaration in object_declarations:
            declaration_args = {
                'type_name': declaration.type.raw_name() 
            } 
            lines.append('export interface %(type_name)s {' % declaration_args)
            
            declaration_properties = filter(lambda member: isinstance(member.type, (AliasedType, ObjectType ,PrimitiveType)), declaration.type_members)            
            for declaration_propertie in declaration_properties:
                member_args = {
                    'name': declaration_propertie.member_name,
                    'type': ts_name_for_primitive_type(domain, declaration_propertie.type),
                    'otpional': '?' if declaration_propertie.is_optional else '',
                    'description': declaration_propertie.description                    
                }
                lines.append('\t%(name)s%(otpional)s: %(type)s; // %(description)s' % member_args)

            lines.append('}\n')

        return lines

    def generate_domain_commands(self, domain):
        lines = []

        for command in domain.commands:
            if len(command.return_parameters) == 0:
                returnParams = 'void'
            elif len(command.return_parameters) > 1:
                returnParams = 'any'
            else:
                returnParams = ", ".join(['%s' % ts_name_for_primitive_type(domain, parameter.type) for parameter in command.return_parameters])

            command_args = {
                'domain': domain.domain_name,
                'commandName': command.command_name,
                'callParams': ", ".join([self.generate_parameter_object(domain, parameter) for parameter in command.call_parameters]),
                'returnParams': returnParams,
                'description': command.description if command.description else 'No description'
            }
            lines.append('\t%(commandName)s(%(callParams)s): %(returnParams)s; // %(description)s' % command_args)
        return lines

    def generate_domain_events(self, domain):
        lines = []

        for event in domain.events:
            returnParams = 'void'

            event_args = {
                'domain': domain.domain_name,
                'commandName': event.event_name,
                'callParams': ", ".join([self.generate_parameter_object(domain, parameter) for parameter in event.event_parameters]),
                'returnParams': returnParams,
                'description': event.description if event.description else 'No description'
            }
            lines.append('\t%(commandName)s(%(callParams)s): %(returnParams)s { } // %(description)s' % event_args)
        return lines

    def generate_parameter_object(self, domain, parameter):
        optional_string = "true" if parameter.is_optional else "false"
        pairs = []
        pair_args = {
            'name': parameter.parameter_name,
            'type': ts_name_for_primitive_type(domain, parameter.type),
            'otpional': '?' if parameter.is_optional else ''
        }

        return "%(name)s%(otpional)s: %(type)s" % pair_args



generator = TypeScriptInterfaceGenerator(protocol)
output = generator.generate_output()
output_file = IncrementalFileWriter(os.path.join("/Users/koeva/work/temp/shit", generator.output_filename()), False)
output_file.write(output)
output_file.close()
# print(output)