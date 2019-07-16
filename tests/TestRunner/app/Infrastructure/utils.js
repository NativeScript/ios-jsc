global.dynamicallyInvokeSelector = function dynamicallyInvokeSelector(obj, sel, resultType) {
    return dynamicallyInvokeSelectorWithArgs(obj, sel, resultType);
}

global.dynamicallyInvokeSelectorWithArgs = function dynamicallyInvokeSelectorWithArgs(obj, sel, resultType, args) {
    const sig = obj.methodSignatureForSelector(sel);
    const invocation = NSInvocation.invocationWithMethodSignature(sig);
    invocation.selector = sel;

    for (let i = 0; args && i < args.length; i++) {
        const ref = new interop.Reference(args[i].type, args[i].value);
        invocation.setArgumentAtIndex(interop.handleof(ref), i + 2); // skip target and selector indices
    }

    
    invocation.target = obj;
    invocation.invokeWithTarget(obj);

    if (!resultType || resultType == interop.types.void)
        return;
    
    const ret = new interop.Reference(resultType, new interop.Pointer());
    invocation.getReturnValue(ret);

    return ret.value;
}
