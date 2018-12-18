#!/usr/bin/env python

import json
import os

from codegen import *

_PRIMITIVE_TO_TS_NAME_MAP = {
    'integer': 'number',
    'object': 'Object'
}

_ALWAYS_UPPERCASED_ENUM_VALUE_SUBSTRINGS = set(['API', 'CSS', 'DOM', 'HTML', 'XHR', 'XML'])


def load_specification(protocol, file_path, is_supplemental=False):
    try:
        with open(file_path, "r") as input_file:
            parsed_json = json.load(input_file)
            protocol.parse_specification(parsed_json, is_supplemental)
    except ValueError:
        raise Exception("Error parsing valid JSON in file: " + file_path)


def generate(combined_domains_path, output_dir):
    protocol = models.Protocol("JavaScriptCore")
    load_specification(protocol, combined_domains_path)
    protocol.resolve_types()

    generator = TypeScriptInterfaceGenerator(protocol)
    output = """declare var __registerDomainDispatcher;
declare var __inspectorSendEvent;
export function DomainDispatcher(domain: string): ClassDecorator {
    return klass => __registerDomainDispatcher(domain, klass);
} \n """
    output += generator.generate_output()

    output_file = open(os.path.join(output_dir, generator.output_filename()), "w")
    output_file.write(output)
    output_file.close()


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
        if parameter_type.is_anonymous:
            type_raw_name = "any /* %s */" % ','.join(parameter_type._values)
        else:
            type_raw_name = Generator.stylized_name_for_enum_value(parameter_type.raw_name())
            if parameter_type.type_domain() != domain:
                type_raw_name = '{}Domain.{}'.format(parameter_type.type_domain().domain_name, type_raw_name)
    elif isinstance(parameter_type, PrimitiveType):
        raw_name = parameter_type.raw_name()
        ts_name = _PRIMITIVE_TO_TS_NAME_MAP.get(raw_name)
        type_raw_name = ts_name if ts_name else raw_name

    return type_raw_name


# noinspection PyMethodMayBeStatic
class TypeScriptInterfaceGenerator(Generator):
    def __init__(self, model):
        Generator.__init__(self, model, "ios", "")

    def output_filename(self):
        return "InspectorBackendCommands.ts"

    def generate_output(self):
        sections = []
        sections.extend(map(self.generate_domain, Generator.domains_to_generate(self)))
        return "\n\n".join(sections)

    def generate_domain(self, domain):
        lines = ['// %s' % domain.domain_name]
        if domain.description:
            lines.append('// %s' % domain.description)
        lines.append('export namespace %sDomain {' % domain.domain_name)

        lines.extend(self.generate_domain_type_declarations(domain))

        if len(domain.all_commands()) > 0:
            lines.extend(self.generate_domain_commands(domain))

        if len(domain.all_events()) > 0:
            lines.append("export class %sFrontend { " % domain.domain_name)
            lines.extend(self.generate_domain_events(domain))
            lines.append('}')

        lines.append('}')
        return '\n'.join(lines)

    def generate_domain_type_declarations(self, domain):
        lines = []
        primitive_declarations = filter(lambda decl: isinstance(decl.type, AliasedType), domain.all_type_declarations())
        object_declarations = filter(lambda decl: isinstance(decl.type, ObjectType), domain.all_type_declarations())
        enum_declarations = filter(lambda decl: isinstance(decl.type, EnumType), domain.all_type_declarations())

        for declaration in primitive_declarations:
            if declaration.description:
                lines.append('// %s' % declaration.description)
            lines.append('export type {} = {}'.format(declaration.type_name,
                                                      ts_name_for_primitive_type(domain,
                                                                                 declaration.type.aliased_type)))

        lines.append('')

        for declaration in object_declarations:
            lines.append('export interface %s {' % declaration.type.raw_name())

            for declaration_property in declaration.type_members:
                member_args = {
                    'name': declaration_property.member_name,
                    'type': ts_name_for_primitive_type(domain, declaration_property.type),
                    'optional': '?' if declaration_property.is_optional else ''
                }
                if declaration_property.description:
                    lines.append('\t// %s' % declaration_property.description)
                lines.append('\t%(name)s%(optional)s: %(type)s;' % member_args)

            lines.append('}\n')

        for declaration in enum_declarations:
            stylized_enums = map(Generator.stylized_name_for_enum_value, declaration.type.enum_values())
            lines.append('export const enum %s { %s }; \n' % (declaration.type.raw_name(), ', '.join(stylized_enums)))

        return lines

    def generate_domain_commands(self, domain):
        lines = []
        commands_lines = []
        argumentslines = []

        commands_lines.append("export interface %sDomainDispatcher { " % domain.domain_name)

        for command in domain.all_commands():
            returnParams = ", ".join(['%s%s: %s' % (parameter.parameter_name, "?" if parameter.is_optional else '',
                                                    ts_name_for_primitive_type(domain, parameter.type)) for parameter in
                                      command.return_parameters])

            argumentInterfaceName = ''
            if len(command.call_parameters) > 0:
                argumentInterfaceName = "%sMethodArguments" % (
                        command.command_name[0].upper() + command.command_name[1:])
                argumentslines.append("export interface %s { " % argumentInterfaceName)
                argumentslines.append(",\n".join(["%s\t%s" % (
                    '\t// %s \n' % parameter.description if parameter.description else '',
                    self.generate_parameter_object(domain, parameter)) for parameter in command.call_parameters]))
                argumentslines.append('}')

            command_args = {
                'domain': domain.domain_name,
                'commandName': command.command_name,
                'argumentInterfaceName': "params: %s" % argumentInterfaceName if argumentInterfaceName else '',
                'returnParams': 'void' if len(returnParams) == 0 else '{ %s }' % returnParams
            }
            if command.description:
                commands_lines.append('\t// %s' % command.description)
            commands_lines.append('\t%(commandName)s(%(argumentInterfaceName)s): %(returnParams)s;' % command_args)

        commands_lines.append('}')

        lines.extend(argumentslines)
        lines.extend(commands_lines)

        return lines

    def generate_domain_events(self, domain):
        lines = []
        for event in domain.all_events():
            parameters = ', '.join(
                '\"{0}\": {0}'.format(parameter.parameter_name) for parameter in event.event_parameters)
            callParams = ", ".join(
                [self.generate_parameter_object(domain, parameter) for parameter in event.event_parameters])
            event_json_message = '{{ \"method\": \"{}.{}\", \"params\": {{ {} }} }}'.format(domain.domain_name,
                                                                                            event.event_name,
                                                                                            parameters)

            if event.description:
                lines.append('\t// %s' % event.description)
            lines.append('\t{0}({1}): void {{ \n\t\t __inspectorSendEvent(JSON.stringify( {2} )); \n\t}}'.format(
                event.event_name, callParams, event_json_message))
        return lines

    def generate_parameter_object(self, domain, parameter):
        pair_args = {
            'name': parameter.parameter_name,
            'type': ts_name_for_primitive_type(domain, parameter.type),
            'optional': '?' if parameter.is_optional else ''
        }

        return "%(name)s%(optional)s: %(type)s" % pair_args
