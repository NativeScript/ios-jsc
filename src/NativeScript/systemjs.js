/*
 * SystemJS v0.16.11
 */
(function() {
function bootstrap() {(function(__global) {

  var isWorker = typeof window == 'undefined' && typeof self != 'undefined' && typeof importScripts != 'undefined';
  var isBrowser = typeof window != 'undefined' && typeof document != 'undefined';
  var isWindows = typeof process != 'undefined' && !!process.platform.match(/^win/);

  if (!__global.console)
    __global.console = { assert: function() {} };

  // IE8 support
  var indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, thisLen = this.length; i < thisLen; i++) {
      if (this[i] === item) {
        return i;
      }
    }
    return -1;
  };
  
  var defineProperty;
  (function () {
    try {
      if (!!Object.defineProperty({}, 'a', {}))
        defineProperty = Object.defineProperty;
    }
    catch (e) {
      defineProperty = function(obj, prop, opt) {
        try {
          obj[prop] = opt.value || opt.get.call(obj);
        }
        catch(e) {}
      }
    }
  })();

  function addToError(err, msg) {
    var newErr;
    if (err instanceof Error) {
      var newErr = new Error(err.message, err.fileName, err.lineNumber);
      newErr.message = err.message + '\n\t' + msg;
      newErr.stack = err.stack;
    }
    else {
      newErr = err + '\n\t' + msg;
    }
      
    return newErr;
  }

  function __eval(source, debugName, context) {
    try {
      new Function(source).call(context);
    }
    catch(e) {
      throw addToError(e, 'Evaluating ' + debugName);
    }
  }

  var baseURI;
  // environent baseURI detection
  if (typeof document != 'undefined' && document.getElementsByTagName) {
    baseURI = document.baseURI;

    if (!baseURI) {
      var bases = document.getElementsByTagName('base');
      baseURI = bases[0] && bases[0].href || window.location.href;
    }

    // sanitize out the hash and querystring
    baseURI = baseURI.split('#')[0].split('?')[0];
    baseURI = baseURI.substr(0, baseURI.lastIndexOf('/') + 1);
  }
  else if (typeof process != 'undefined' && process.cwd) {
    baseURI = 'file://' + (isWindows ? '/' : '') + process.cwd() + '/';
    if (isWindows)
      baseURI = baseURI.replace(/\\/g, '/');
  }
  else if (typeof location != 'undefined') {
    baseURI = __global.location.href;
  }
  else {
    baseURI = NSBundle.mainBundle().bundlePath + "/app/";
    //throw new TypeError('No environment baseURI');
  }

  var URL = typeof __global.URL == 'function' && __global.URL || URLPolyfill;
// from https://gist.github.com/Yaffle/1088850
function URLPolyfill(url, baseURL) {
  if (typeof url != 'string')
    throw new TypeError('URL must be a string');
  var m = String(url).replace(/^\s+|\s+$/g, "").match(/^([^:\/?#]+:)?(?:\/\/(?:([^:@\/?#]*)(?::([^:@\/?#]*))?@)?(([^:\/?#]*)(?::(\d*))?))?([^?#]*)(\?[^#]*)?(#[\s\S]*)?/);
  if (!m) {
    throw new RangeError();
  }
  var protocol = m[1] || "";
  var username = m[2] || "";
  var password = m[3] || "";
  var host = m[4] || "";
  var hostname = m[5] || "";
  var port = m[6] || "";
  var pathname = m[7] || "";
  var search = m[8] || "";
  var hash = m[9] || "";
  if (baseURL !== undefined) {
    var base = baseURL instanceof URLPolyfill ? baseURL : new URLPolyfill(baseURL);
    var flag = protocol === "" && host === "" && username === "";
    if (flag && pathname === "" && search === "") {
      search = base.search;
    }
    if (flag && pathname.charAt(0) !== "/") {
      pathname = (pathname !== "" ? (((base.host !== "" || base.username !== "") && base.pathname === "" ? "/" : "") + base.pathname.slice(0, base.pathname.lastIndexOf("/") + 1) + pathname) : base.pathname);
    }
    // dot segments removal
    var output = [];
    pathname.replace(/^(\.\.?(\/|$))+/, "")
      .replace(/\/(\.(\/|$))+/g, "/")
      .replace(/\/\.\.$/, "/../")
      .replace(/\/?[^\/]*/g, function (p) {
        if (p === "/..") {
          output.pop();
        } else {
          output.push(p);
        }
      });
    pathname = output.join("").replace(/^\//, pathname.charAt(0) === "/" ? "/" : "");
    if (flag) {
      port = base.port;
      hostname = base.hostname;
      host = base.host;
      password = base.password;
      username = base.username;
    }
    if (protocol === "") {
      protocol = base.protocol;
    }
  }

  // convert windows file URLs to use /
  if (protocol == 'file:')
    pathname = pathname.replace(/\\/g, '/');

  this.origin = protocol + (protocol !== "" || host !== "" ? "//" : "") + host;
  this.href = protocol + (protocol !== "" || host !== "" ? "//" : "") + (username !== "" ? username + (password !== "" ? ":" + password : "") + "@" : "") + host + pathname + search + hash;
  this.protocol = protocol;
  this.username = username;
  this.password = password;
  this.host = host;
  this.hostname = hostname;
  this.port = port;
  this.pathname = pathname;
  this.search = search;
  this.hash = hash;
}
(typeof self != 'undefined' ? self : global).URLPolyfill = URLPolyfill;/*
*********************************************************************************************

  Dynamic Module Loader Polyfill

    - Implemented exactly to the former 2014-08-24 ES6 Specification Draft Rev 27, Section 15
      http://wiki.ecmascript.org/doku.php?id=harmony:specification_drafts#august_24_2014_draft_rev_27

    - Functions are commented with their spec numbers, with spec differences commented.

    - Spec bugs are commented in this code with links.

    - Abstract functions have been combined where possible, and their associated functions
      commented.

    - Realm implementation is entirely omitted.

*********************************************************************************************
*/

function Module() {}
function Loader(options) {
  this._loader = {
    loaderObj: this,
    loads: [],
    modules: {},
    importPromises: {},
    moduleRecords: {}
  };

  // 26.3.3.6
  defineProperty(this, 'global', {
    get: function() {
      return __global;
    }
  });

  // 26.3.3.13 realm not implemented
}

(function() {

// Some Helpers

// logs a linkset snapshot for debugging
/* function snapshot(loader) {
  console.log('---Snapshot---');
  for (var i = 0; i < loader.loads.length; i++) {
    var load = loader.loads[i];
    var linkSetLog = '  ' + load.name + ' (' + load.status + '): ';

    for (var j = 0; j < load.linkSets.length; j++) {
      linkSetLog += '{' + logloads(load.linkSets[j].loads) + '} ';
    }
    console.log(linkSetLog);
  }
  console.log('');
}
function logloads(loads) {
  var log = '';
  for (var k = 0; k < loads.length; k++)
    log += loads[k].name + (k != loads.length - 1 ? ' ' : '');
  return log;
} */


/* function checkInvariants() {
  // see https://bugs.ecmascript.org/show_bug.cgi?id=2603#c1

  var loads = System._loader.loads;
  var linkSets = [];

  for (var i = 0; i < loads.length; i++) {
    var load = loads[i];
    console.assert(load.status == 'loading' || load.status == 'loaded', 'Each load is loading or loaded');

    for (var j = 0; j < load.linkSets.length; j++) {
      var linkSet = load.linkSets[j];

      for (var k = 0; k < linkSet.loads.length; k++)
        console.assert(loads.indexOf(linkSet.loads[k]) != -1, 'linkSet loads are a subset of loader loads');

      if (linkSets.indexOf(linkSet) == -1)
        linkSets.push(linkSet);
    }
  }

  for (var i = 0; i < loads.length; i++) {
    var load = loads[i];
    for (var j = 0; j < linkSets.length; j++) {
      var linkSet = linkSets[j];

      if (linkSet.loads.indexOf(load) != -1)
        console.assert(load.linkSets.indexOf(linkSet) != -1, 'linkSet contains load -> load contains linkSet');

      if (load.linkSets.indexOf(linkSet) != -1)
        console.assert(linkSet.loads.indexOf(load) != -1, 'load contains linkSet -> linkSet contains load');
    }
  }

  for (var i = 0; i < linkSets.length; i++) {
    var linkSet = linkSets[i];
    for (var j = 0; j < linkSet.loads.length; j++) {
      var load = linkSet.loads[j];

      for (var k = 0; k < load.dependencies.length; k++) {
        var depName = load.dependencies[k].value;
        var depLoad;
        for (var l = 0; l < loads.length; l++) {
          if (loads[l].name != depName)
            continue;
          depLoad = loads[l];
          break;
        }

        // loading records are allowed not to have their dependencies yet
        // if (load.status != 'loading')
        //  console.assert(depLoad, 'depLoad found');

        // console.assert(linkSet.loads.indexOf(depLoad) != -1, 'linkset contains all dependencies');
      }
    }
  }
} */

  // 15.2.3 - Runtime Semantics: Loader State

  // 15.2.3.11
  function createLoaderLoad(object) {
    return {
      // modules is an object for ES5 implementation
      modules: {},
      loads: [],
      loaderObj: object
    };
  }

  // 15.2.3.2 Load Records and LoadRequest Objects

  // 15.2.3.2.1
  function createLoad(name) {
    return {
      status: 'loading',
      name: name,
      linkSets: [],
      dependencies: [],
      metadata: {}
    };
  }

  // 15.2.3.2.2 createLoadRequestObject, absorbed into calling functions

  // 15.2.4

  // 15.2.4.1
  function loadModule(loader, name, options) {
    return new Promise(asyncStartLoadPartwayThrough({
      step: options.address ? 'fetch' : 'locate',
      loader: loader,
      moduleName: name,
      // allow metadata for import https://bugs.ecmascript.org/show_bug.cgi?id=3091
      moduleMetadata: options && options.metadata || {},
      moduleSource: options.source,
      moduleAddress: options.address
    }));
  }

  // 15.2.4.2
  function requestLoad(loader, request, refererName, refererAddress) {
    // 15.2.4.2.1 CallNormalize
    return new Promise(function(resolve, reject) {
      resolve(loader.loaderObj.normalize(request, refererName, refererAddress));
    })
    // 15.2.4.2.2 GetOrCreateLoad
    .then(function(name) {
      var load;
      if (loader.modules[name]) {
        load = createLoad(name);
        load.status = 'linked';
        // https://bugs.ecmascript.org/show_bug.cgi?id=2795
        load.module = loader.modules[name];
        return load;
      }

      for (var i = 0, l = loader.loads.length; i < l; i++) {
        load = loader.loads[i];
        if (load.name != name)
          continue;
        console.assert(load.status == 'loading' || load.status == 'loaded', 'loading or loaded');
        return load;
      }

      load = createLoad(name);
      loader.loads.push(load);

      proceedToLocate(loader, load);

      return load;
    });
  }

  // 15.2.4.3
  function proceedToLocate(loader, load) {
    proceedToFetch(loader, load,
      Promise.resolve()
      // 15.2.4.3.1 CallLocate
      .then(function() {
        return loader.loaderObj.locate({ name: load.name, metadata: load.metadata });
      })
    );
  }

  // 15.2.4.4
  function proceedToFetch(loader, load, p) {
    proceedToTranslate(loader, load,
      p
      // 15.2.4.4.1 CallFetch
      .then(function(address) {
        // adjusted, see https://bugs.ecmascript.org/show_bug.cgi?id=2602
        if (load.status != 'loading')
          return;
        load.address = address;

        return loader.loaderObj.fetch({ name: load.name, metadata: load.metadata, address: address });
      })
    );
  }

  var anonCnt = 0;

  // 15.2.4.5
  function proceedToTranslate(loader, load, p) {
    p
    // 15.2.4.5.1 CallTranslate
    .then(function(source) {
      if (load.status != 'loading')
        return;

      return Promise.resolve(loader.loaderObj.translate({ name: load.name, metadata: load.metadata, address: load.address, source: source }))

      // 15.2.4.5.2 CallInstantiate
      .then(function(source) {
        load.source = source;
        return loader.loaderObj.instantiate({ name: load.name, metadata: load.metadata, address: load.address, source: source });
      })

      // 15.2.4.5.3 InstantiateSucceeded
      .then(function(instantiateResult) {
        if (instantiateResult === undefined) {
          load.address = load.address || '<Anonymous Module ' + ++anonCnt + '>';

          // instead of load.kind, use load.isDeclarative
          load.isDeclarative = true;
          return transpile.call(loader.loaderObj, load)
          .then(function(transpiled) {
            // Hijack System.register to set declare function
            var curSystem = __global.System;
            var curRegister = curSystem.register;
            curSystem.register = function(name, deps, declare) {
              if (typeof name != 'string') {
                declare = deps;
                deps = name;
              }
              // store the registered declaration as load.declare
              // store the deps as load.deps
              load.declare = declare;
              load.depsList = deps;
            }
            // empty {} context is closest to undefined 'this' we can get
            __eval(transpiled, load.address, {});
            curSystem.register = curRegister;
          });
        }
        else if (typeof instantiateResult == 'object') {
          load.depsList = instantiateResult.deps || [];
          load.execute = instantiateResult.execute;
          load.isDeclarative = false;
        }
        else
          throw TypeError('Invalid instantiate return value');
      })
      // 15.2.4.6 ProcessLoadDependencies
      .then(function() {
        load.dependencies = [];
        var depsList = load.depsList;

        var loadPromises = [];
        for (var i = 0, l = depsList.length; i < l; i++) (function(request, index) {
          loadPromises.push(
            requestLoad(loader, request, load.name, load.address)

            // 15.2.4.6.1 AddDependencyLoad (load is parentLoad)
            .then(function(depLoad) {

              // adjusted from spec to maintain dependency order
              // this is due to the System.register internal implementation needs
              load.dependencies[index] = {
                key: request,
                value: depLoad.name
              };

              if (depLoad.status != 'linked') {
                var linkSets = load.linkSets.concat([]);
                for (var i = 0, l = linkSets.length; i < l; i++)
                  addLoadToLinkSet(linkSets[i], depLoad);
              }

              // console.log('AddDependencyLoad ' + depLoad.name + ' for ' + load.name);
              // snapshot(loader);
            })
          );
        })(depsList[i], i);

        return Promise.all(loadPromises);
      })

      // 15.2.4.6.2 LoadSucceeded
      .then(function() {
        // console.log('LoadSucceeded ' + load.name);
        // snapshot(loader);

        console.assert(load.status == 'loading', 'is loading');

        load.status = 'loaded';

        var linkSets = load.linkSets.concat([]);
        for (var i = 0, l = linkSets.length; i < l; i++)
          updateLinkSetOnLoad(linkSets[i], load);
      });
    })
    // 15.2.4.5.4 LoadFailed
    ['catch'](function(exc) {
      load.status = 'failed';
      load.exception = exc;

      var linkSets = load.linkSets.concat([]);
      for (var i = 0, l = linkSets.length; i < l; i++) {
        linkSetFailed(linkSets[i], load, exc);
      }

      console.assert(load.linkSets.length == 0, 'linkSets not removed');
    });
  }

  // 15.2.4.7 PromiseOfStartLoadPartwayThrough absorbed into calling functions

  // 15.2.4.7.1
  function asyncStartLoadPartwayThrough(stepState) {
    return function(resolve, reject) {
      var loader = stepState.loader;
      var name = stepState.moduleName;
      var step = stepState.step;

      if (loader.modules[name])
        throw new TypeError('"' + name + '" already exists in the module table');

      // adjusted to pick up existing loads
      var existingLoad;
      for (var i = 0, l = loader.loads.length; i < l; i++) {
        if (loader.loads[i].name == name) {
          existingLoad = loader.loads[i];

          if(step == 'translate' && !existingLoad.source) {
            existingLoad.address = stepState.moduleAddress;
            proceedToTranslate(loader, existingLoad, Promise.resolve(stepState.moduleSource));
          }

          return existingLoad.linkSets[0].done.then(function() {
            resolve(existingLoad);
          });
        }
      }

      var load = createLoad(name);

      load.metadata = stepState.moduleMetadata;

      var linkSet = createLinkSet(loader, load);

      loader.loads.push(load);

      resolve(linkSet.done);

      if (step == 'locate')
        proceedToLocate(loader, load);

      else if (step == 'fetch')
        proceedToFetch(loader, load, Promise.resolve(stepState.moduleAddress));

      else {
        console.assert(step == 'translate', 'translate step');
        load.address = stepState.moduleAddress;
        proceedToTranslate(loader, load, Promise.resolve(stepState.moduleSource));
      }
    }
  }

  // Declarative linking functions run through alternative implementation:
  // 15.2.5.1.1 CreateModuleLinkageRecord not implemented
  // 15.2.5.1.2 LookupExport not implemented
  // 15.2.5.1.3 LookupModuleDependency not implemented

  // 15.2.5.2.1
  function createLinkSet(loader, startingLoad) {
    var linkSet = {
      loader: loader,
      loads: [],
      startingLoad: startingLoad, // added see spec bug https://bugs.ecmascript.org/show_bug.cgi?id=2995
      loadingCount: 0
    };
    linkSet.done = new Promise(function(resolve, reject) {
      linkSet.resolve = resolve;
      linkSet.reject = reject;
    });
    addLoadToLinkSet(linkSet, startingLoad);
    return linkSet;
  }
  // 15.2.5.2.2
  function addLoadToLinkSet(linkSet, load) {
    console.assert(load.status == 'loading' || load.status == 'loaded', 'loading or loaded on link set');

    for (var i = 0, l = linkSet.loads.length; i < l; i++)
      if (linkSet.loads[i] == load)
        return;

    linkSet.loads.push(load);
    load.linkSets.push(linkSet);

    // adjustment, see https://bugs.ecmascript.org/show_bug.cgi?id=2603
    if (load.status != 'loaded') {
      linkSet.loadingCount++;
    }

    var loader = linkSet.loader;

    for (var i = 0, l = load.dependencies.length; i < l; i++) {
      var name = load.dependencies[i].value;

      if (loader.modules[name])
        continue;

      for (var j = 0, d = loader.loads.length; j < d; j++) {
        if (loader.loads[j].name != name)
          continue;

        addLoadToLinkSet(linkSet, loader.loads[j]);
        break;
      }
    }
    // console.log('add to linkset ' + load.name);
    // snapshot(linkSet.loader);
  }

  // linking errors can be generic or load-specific
  // this is necessary for debugging info
  function doLink(linkSet) {
    var error = false;
    try {
      link(linkSet, function(load, exc) {
        linkSetFailed(linkSet, load, exc);
        error = true;
      });
    }
    catch(e) {
      linkSetFailed(linkSet, null, e);
      error = true;
    }
    return error;
  }

  // 15.2.5.2.3
  function updateLinkSetOnLoad(linkSet, load) {
    // console.log('update linkset on load ' + load.name);
    // snapshot(linkSet.loader);

    console.assert(load.status == 'loaded' || load.status == 'linked', 'loaded or linked');

    linkSet.loadingCount--;

    if (linkSet.loadingCount > 0)
      return;

    // adjusted for spec bug https://bugs.ecmascript.org/show_bug.cgi?id=2995
    var startingLoad = linkSet.startingLoad;

    // non-executing link variation for loader tracing
    // on the server. Not in spec.
    /***/
    if (linkSet.loader.loaderObj.execute === false) {
      var loads = [].concat(linkSet.loads);
      for (var i = 0, l = loads.length; i < l; i++) {
        var load = loads[i];
        load.module = !load.isDeclarative ? {
          module: _newModule({})
        } : {
          name: load.name,
          module: _newModule({}),
          evaluated: true
        };
        load.status = 'linked';
        finishLoad(linkSet.loader, load);
      }
      return linkSet.resolve(startingLoad);
    }
    /***/

    var abrupt = doLink(linkSet);

    if (abrupt)
      return;

    console.assert(linkSet.loads.length == 0, 'loads cleared');

    linkSet.resolve(startingLoad);
  }

  // 15.2.5.2.4
  function linkSetFailed(linkSet, load, exc) {
    var loader = linkSet.loader;

    if (load) {
      if (load && linkSet.loads[0].name != load.name)
        exc = addToError(exc, 'Error loading ' + load.name + ' from ' + linkSet.loads[0].name);

      if (load)
        exc = addToError(exc, 'Error loading ' + load.name);
    }
    else {
      exc = addToError(exc, 'Error linking ' + linkSet.loads[0].name);
    }


    var loads = linkSet.loads.concat([]);
    for (var i = 0, l = loads.length; i < l; i++) {
      var load = loads[i];

      // store all failed load records
      loader.loaderObj.failed = loader.loaderObj.failed || [];
      if (indexOf.call(loader.loaderObj.failed, load) == -1)
        loader.loaderObj.failed.push(load);

      var linkIndex = indexOf.call(load.linkSets, linkSet);
      console.assert(linkIndex != -1, 'link not present');
      load.linkSets.splice(linkIndex, 1);
      if (load.linkSets.length == 0) {
        var globalLoadsIndex = indexOf.call(linkSet.loader.loads, load);
        if (globalLoadsIndex != -1)
          linkSet.loader.loads.splice(globalLoadsIndex, 1);
      }
    }
    linkSet.reject(exc);
  }

  // 15.2.5.2.5
  function finishLoad(loader, load) {
    // add to global trace if tracing
    if (loader.loaderObj.trace) {
      if (!loader.loaderObj.loads)
        loader.loaderObj.loads = {};
      var depMap = {};
      load.dependencies.forEach(function(dep) {
        depMap[dep.key] = dep.value;
      });
      loader.loaderObj.loads[load.name] = {
        name: load.name,
        deps: load.dependencies.map(function(dep){ return dep.key }),
        depMap: depMap,
        address: load.address,
        metadata: load.metadata,
        source: load.source,
        kind: load.isDeclarative ? 'declarative' : 'dynamic'
      };
    }
    // if not anonymous, add to the module table
    if (load.name) {
      console.assert(!loader.modules[load.name], 'load not in module table');
      loader.modules[load.name] = load.module;
    }
    var loadIndex = indexOf.call(loader.loads, load);
    if (loadIndex != -1)
      loader.loads.splice(loadIndex, 1);
    for (var i = 0, l = load.linkSets.length; i < l; i++) {
      loadIndex = indexOf.call(load.linkSets[i].loads, load);
      if (loadIndex != -1)
        load.linkSets[i].loads.splice(loadIndex, 1);
    }
    load.linkSets.splice(0, load.linkSets.length);
  }

  function doDynamicExecute(linkSet, load, linkError) {
    try {
      var module = load.execute();
    }
    catch(e) {
      linkError(load, e);
      return;
    }
    if (!module || !(module instanceof Module))
      linkError(load, new TypeError('Execution must define a Module instance'));
    else
      return module;
  }

  // 26.3 Loader

  // 26.3.1.1
  // defined at top

  // importPromises adds ability to import a module twice without error - https://bugs.ecmascript.org/show_bug.cgi?id=2601
  function createImportPromise(loader, name, promise) {
    var importPromises = loader._loader.importPromises;
    return importPromises[name] = promise.then(function(m) {
      importPromises[name] = undefined;
      return m;
    }, function(e) {
      importPromises[name] = undefined;
      throw e;
    });
  }

  Loader.prototype = {
    // 26.3.3.1
    constructor: Loader,
    // 26.3.3.2
    define: function(name, source, options) {
      // check if already defined
      if (this._loader.importPromises[name])
        throw new TypeError('Module is already loading.');
      return createImportPromise(this, name, new Promise(asyncStartLoadPartwayThrough({
        step: 'translate',
        loader: this._loader,
        moduleName: name,
        moduleMetadata: options && options.metadata || {},
        moduleSource: source,
        moduleAddress: options && options.address
      })));
    },
    // 26.3.3.3
    'delete': function(name) {
      var loader = this._loader;
      delete loader.importPromises[name];
      delete loader.moduleRecords[name];
      return loader.modules[name] ? delete loader.modules[name] : false;
    },
    // 26.3.3.4 entries not implemented
    // 26.3.3.5
    get: function(key) {
      if (!this._loader.modules[key])
        return;
      doEnsureEvaluated(this._loader.modules[key], [], this);
      return this._loader.modules[key].module;
    },
    // 26.3.3.7
    has: function(name) {
      return !!this._loader.modules[name];
    },
    // 26.3.3.8
    'import': function(name, parentName, parentAddress) {
      if (typeof parentName == 'object')
        parentName = parentName.name;

      // run normalize first
      var loaderObj = this;

      // added, see https://bugs.ecmascript.org/show_bug.cgi?id=2659
      return Promise.resolve(loaderObj.normalize(name, parentName))
      .then(function(name) {
        var loader = loaderObj._loader;

        if (loader.modules[name]) {
          doEnsureEvaluated(loader.modules[name], [], loader._loader);
          return loader.modules[name].module;
        }

        return loader.importPromises[name] || createImportPromise(loaderObj, name,
          loadModule(loader, name, {})
          .then(function(load) {
            delete loader.importPromises[name];
            return evaluateLoadedModule(loader, load);
          }));
      });
    },
    // 26.3.3.9 keys not implemented
    // 26.3.3.10
    load: function(name, options) {
      if (this._loader.modules[name]) {
        doEnsureEvaluated(this._loader.modules[name], [], this._loader);
        return Promise.resolve(this._loader.modules[name].module);
      }
      return this._loader.importPromises[name] || createImportPromise(this, name, loadModule(this._loader, name, {}));
    },
    // 26.3.3.11
    module: function(source, options) {
      var load = createLoad();
      load.address = options && options.address;
      var linkSet = createLinkSet(this._loader, load);
      var sourcePromise = Promise.resolve(source);
      var loader = this._loader;
      var p = linkSet.done.then(function() {
        return evaluateLoadedModule(loader, load);
      });
      proceedToTranslate(loader, load, sourcePromise);
      return p;
    },
    // 26.3.3.12
    newModule: function (obj) {
      if (typeof obj != 'object')
        throw new TypeError('Expected object');

      // we do this to be able to tell if a module is a module privately in ES5
      // by doing m instanceof Module
      var m = new Module();

      var pNames;
      if (Object.getOwnPropertyNames && obj != null) {
        pNames = Object.getOwnPropertyNames(obj);
      }
      else {
        pNames = [];
        for (var key in obj)
          pNames.push(key);
      }

      for (var i = 0; i < pNames.length; i++) (function(key) {
        defineProperty(m, key, {
          configurable: false,
          enumerable: true,
          get: function () {
            return obj[key];
          }
        });
      })(pNames[i]);

      if (Object.preventExtensions)
        Object.preventExtensions(m);

      return m;
    },
    // 26.3.3.14
    set: function(name, module) {
      if (!(module instanceof Module))
        throw new TypeError('Loader.set(' + name + ', module) must be a module');
      this._loader.modules[name] = {
        module: module
      };
    },
    // 26.3.3.15 values not implemented
    // 26.3.3.16 @@iterator not implemented
    // 26.3.3.17 @@toStringTag not implemented

    // 26.3.3.18.1
    normalize: function(name, referrerName, referrerAddress) {
      return name;
    },
    // 26.3.3.18.2
    locate: function(load) {
      return load.name;
    },
    // 26.3.3.18.3
    fetch: function(load) {
    },
    // 26.3.3.18.4
    translate: function(load) {
      return load.source;
    },
    // 26.3.3.18.5
    instantiate: function(load) {
    }
  };

  var _newModule = Loader.prototype.newModule;
/*
 * ES6 Module Declarative Linking Code - Dev Build Only
 */
  function link(linkSet, linkError) {

    var loader = linkSet.loader;

    if (!linkSet.loads.length)
      return;

    var loads = linkSet.loads.concat([]);

    for (var i = 0; i < loads.length; i++) {
      var load = loads[i];

      var module = doDynamicExecute(linkSet, load, linkError);
      if (!module)
        return;
      load.module = {
        name: load.name,
        module: module
      };
      load.status = 'linked';

      finishLoad(loader, load);
    }
  }

  function evaluateLoadedModule(loader, load) {
    console.assert(load.status == 'linked', 'is linked ' + load.name);
    return load.module.module;
  }

  function doEnsureEvaluated() {}
})();/*
*********************************************************************************************

  System Loader Implementation

    - Implemented to https://github.com/jorendorff/js-loaders/blob/master/browser-loader.js

    - <script type="module"> supported

*********************************************************************************************
*/

var System;

function SystemLoader() {
  Loader.call(this);
  this.paths = {};
}

// NB no specification provided for System.paths, used ideas discussed in https://github.com/jorendorff/js-loaders/issues/25
function applyPaths(loader, name) {
  // most specific (most number of slashes in path) match wins
  var pathMatch = '', wildcard, maxSlashCount = 0;

  // check to see if we have a paths entry
  for (var p in loader.paths) {
    var pathParts = p.split('*');
    if (pathParts.length > 2)
      throw new TypeError('Only one wildcard in a path is permitted');

    // exact path match
    if (pathParts.length == 1) {
      if (name == p) {
        pathMatch = p;
        break;
      }
    }
    // wildcard path match
    else {
      var slashCount = p.split('/').length;
      if (slashCount >= maxSlashCount &&
          name.substr(0, pathParts[0].length) == pathParts[0] &&
          name.substr(name.length - pathParts[1].length) == pathParts[1]) {
            maxSlashCount = slashCount;
            pathMatch = p;
            wildcard = name.substr(pathParts[0].length, name.length - pathParts[1].length - pathParts[0].length);
          }
    }
  }

  var outPath = loader.paths[pathMatch] || name;
  if (wildcard)
    outPath = outPath.replace('*', wildcard);

  return outPath;
}

// inline Object.create-style class extension
function LoaderProto() {}
LoaderProto.prototype = Loader.prototype;
SystemLoader.prototype = new LoaderProto();
  var fetchTextFromURL;
  if (typeof XMLHttpRequest != 'undefined') {
    fetchTextFromURL = function(url, fulfill, reject) {
      // percent encode just '#' in urls
      // according to https://github.com/jorendorff/js-loaders/blob/master/browser-loader.js#L238
      // we should encode everything, but it breaks for servers that don't expect it
      // like in (https://github.com/systemjs/systemjs/issues/168)
      if (isBrowser)
        url = url.replace(/#/g, '%23');

      var xhr = new XMLHttpRequest();
      var sameDomain = true;
      var doTimeout = false;
      if (!('withCredentials' in xhr)) {
        // check if same domain
        var domainCheck = /^(\w+:)?\/\/([^\/]+)/.exec(url);
        if (domainCheck) {
          sameDomain = domainCheck[2] === window.location.host;
          if (domainCheck[1])
            sameDomain &= domainCheck[1] === window.location.protocol;
        }
      }
      if (!sameDomain && typeof XDomainRequest != 'undefined') {
        xhr = new XDomainRequest();
        xhr.onload = load;
        xhr.onerror = error;
        xhr.ontimeout = error;
        xhr.onprogress = function() {};
        xhr.timeout = 0;
        doTimeout = true;
      }
      function load() {
        fulfill(xhr.responseText);
      }
      function error() {
        reject(xhr.statusText + ': ' + url || 'XHR error');
      }

      xhr.onreadystatechange = function () {
        if (xhr.readyState === 4) {
          if (xhr.status === 200 || (xhr.status == 0 && xhr.responseText)) {
            load();
          } else {
            error();
          }
        }
      };
      xhr.open("GET", url, true);

      if (doTimeout)
        setTimeout(function() {
          xhr.send();
        }, 0);

      xhr.send(null);
    };
  }
  else if (typeof require != 'undefined') {
    var fs;
    fetchTextFromURL = function(url, fulfill, reject) {
      if (url.substr(0, 8) != 'file:///')
        throw 'Only file URLs of the form file:/// allowed running in Node.';
      fs = fs || require('fs');
      if (isWindows)
        url = url.replace(/\//g, '\\').substr(8);
      else
        url = url.substr(7);
      return fs.readFile(url, function(err, data) {
        if (err)
          return reject(err);
        else
          fulfill(data + '');
      });
    };
  }
  else {
    fetchTextFromURL = function(url, fulfill, reject) {
      throw new TypeError('No environment fetch API available.');
    }
  }

  SystemLoader.prototype.fetch = function(load) {
    return new Promise(function(resolve, reject) {
      fetchTextFromURL(load.address, resolve, reject);
    });
  };/*
 * Traceur, Babel and TypeScript transpile hook for Loader
 */
var transpile = (function() {

  // use Traceur by default
  Loader.prototype.transpiler = 'traceur';

  function transpile(load) {
    var self = this;

    return Promise.resolve(__global[self.transpiler == 'typescript' ? 'ts' : self.transpiler]
        || (self.pluginLoader || self)['import'](self.transpiler))
    .then(function(transpiler) {
      if (transpiler.__useDefault)
        transpiler = transpiler['default'];

      var transpileFunction;
      if (transpiler.Compiler)
        transpileFunction = traceurTranspile;
      else if (transpiler.createLanguageService)
        transpileFunction = typescriptTranspile;
      else
        transpileFunction = babelTranspile;

      // note __moduleName will be part of the transformer meta in future when we have the spec for this
      return 'var __moduleName = "' + load.name + '";' + transpileFunction.call(self, load, transpiler) + '\n//# sourceURL=' + load.address + '!transpiled';
    });
  };

  function traceurTranspile(load, traceur) {
    var options = this.traceurOptions || {};
    options.modules = 'instantiate';
    options.script = false;
    options.sourceMaps = 'inline';
    options.filename = load.address;
    options.inputSourceMap = load.metadata.sourceMap;
    options.moduleName = false;

    var compiler = new traceur.Compiler(options);

    return doTraceurCompile(load.source, compiler, options.filename);
  }
  function doTraceurCompile(source, compiler, filename) {
    try {
      return compiler.compile(source, filename);
    }
    catch(e) {
      // traceur throws an error array
      throw e[0];
    }
  }

  function babelTranspile(load, babel) {
    var options = this.babelOptions || {};
    options.modules = 'system';
    options.sourceMap = 'inline';
    options.inputSourceMap = load.metadata.sourceMap;
    options.filename = load.address;
    options.code = true;
    options.ast = false;

    return babel.transform(load.source, options).code;
  }

  function typescriptTranspile(load, ts) {
    var options = this.typescriptOptions || {};
    if (options.target === undefined) {
      options.target = ts.ScriptTarget.ES5;
    }
    options.module = ts.ModuleKind.System;
    options.inlineSourceMap = true;

    return ts.transpile(load.source, options, load.address);
  }

  return transpile;
})();
// we define a __exec for globally-scoped execution
// used by module format implementations
var __exec;

(function() {

  // System clobbering protection (mostly for Traceur)
  var curSystem;
  function preExec(loader) {
    curSystem = __global.System;
    __global.System = loader;
  }
  function postExec() {
    __global.System = curSystem;
  }

  function getSource(load) {
    // adds the sourceURL comment if not already present
    var lastLineIndex = load.source.lastIndexOf('\n');
    return load.source + (load.source.substr(lastLineIndex, 15) != '\n//# sourceURL=' ? '\n//# sourceURL=' + load.address : '');
  }

  // use script injection eval to get identical global script behaviour
  if (typeof document != 'undefined') {
    var head;

    var scripts = document.getElementsByTagName('script');
    $__curScript = scripts[scripts.length - 1];

    __exec = function(load) {
      if (!head)
        head = document.head || document.body || document.documentElement;

      var script = document.createElement('script');
      script.text = getSource(load);
      var onerror = window.onerror;
      var e;
      window.onerror = function(_e) {
        e = addToError(_e, 'Evaluating ' + load.address);
      }
      preExec(this);
      head.appendChild(script);
      head.removeChild(script);
      postExec();
      window.onerror = onerror;
      if (e)
        throw e;
    }
  }
  // Web Worker uses original ESML eval
  // this may lead to some global module execution differences (eg var not defining onto global)
  else if (isWorker) {
    __exec = function(load) {
      try {
        preExec(this);
        new Function(getSource(load)).call(__global);
        postExec();
      }
      catch(e) {
        throw addToError(e, 'Evaluating ' + load.address);
      }
    };
  }
  else if (typeof process != 'undefined' && process.cwd) {
    // global scoped eval for node
    var vmModule = 'vm';
    var vm = require(vmModule);
    __exec = function(load) {
      try {
        preExec(this);
        vm.runInThisContext(getSource(load));
        postExec();
      }
      catch(e) {
        throw addToError(e, 'Evaluating ' + load.address);
      }
    };
  }
  else {
    __exec = function(load, globals, thisValue) {
      try {
        preExec(this);
        new Function(getSource(load, globals, thisValue)).call(__global);
        postExec();
        __global._g = undefined;
      }
      catch(e) {
        throw addToError(e, 'Evaluating ' + load.address);
      }
    };
  }

})();// SystemJS Loader Class and Extension helpers

function SystemJSLoader() {
  SystemLoader.call(this);

  systemJSConstructor.call(this);
}

// inline Object.create-style class extension
function SystemProto() {};
SystemProto.prototype = SystemLoader.prototype;
SystemJSLoader.prototype = new SystemProto();

var systemJSConstructor;

function hook(name, hook) {
  SystemJSLoader.prototype[name] = hook(SystemJSLoader.prototype[name]);
}
function hookConstructor(hook) {
  systemJSConstructor = hook(systemJSConstructor || function() {});
}

function dedupe(deps) {
  var newDeps = [];
  for (var i = 0, l = deps.length; i < l; i++)
    if (indexOf.call(newDeps, deps[i]) == -1)
      newDeps.push(deps[i])
  return newDeps;
}

function extend(a, b, underwrite) {
  for (var p in b) {
    if (!underwrite || !(p in a))
      a[p] = b[p];
  }
}var absURLRegEx = /^[^\/]+:\/\//;

function readMemberExpression(p, value) {
  var pParts = p.split('.');
  while (pParts.length)
    value = value[pParts.shift()];
  return value;
}

var baseURLCache = {};
function getBaseURLObj() {
  if (baseURLCache[this.baseURL])
    return baseURLCache[this.baseURL];

  // normalize baseURL if not already
  if (this.baseURL[this.baseURL.length - 1] != '/')
    this.baseURL += '/';

  var baseURL = new URL(this.baseURL, baseURI);

  this.baseURL = baseURL.href;

  return (baseURLCache[this.baseURL] = baseURL);
}

var baseURIObj = new URL(baseURI);

(function() {

hookConstructor(function(constructor) {
  return function() {
    constructor.call(this);

    // support baseURL
    this.baseURL = baseURI.substr(0, baseURI.lastIndexOf('/') + 1);

    // support the empty module, as a concept
    this.set('@empty', this.newModule({}));
  };
});

/*
  Normalization

  If a name is relative, we apply URL normalization to the page
  If a name is an absolute URL, we leave it as-is

  Plain names (neither of the above) run through the map and package
  normalization phases (applying before and after this one).

  The paths normalization phase applies last (paths extension), which
  defines the `normalizeSync` function and normalizes everything into
  a URL.

  The final normalization 
 */
hook('normalize', function() {
  var coreModulesRoot = NSString.pathWithComponents([baseURI, "tns_modules"]) + "/";
  var fileManager = NSFileManager.defaultManager();

  return function(name, parentName) {
    // relative URL-normalization
    var basePath = (name[0] == '.' || name[0] == '/') ? (parentName || baseURIObj) : coreModulesRoot;
    var url = new URL(name, basePath).href;
    var urlAsNsString = NSString.stringWithString(url);

    var isDirectory = new interop.Reference(interop.types.bool, false);
    if (fileManager.fileExistsAtPathIsDirectory(urlAsNsString, isDirectory)) {
      if(isDirectory.value) { // if is folder - search for main file in the folder
        var mainFile = "index.js";
        var packageJsonPath = urlAsNsString.stringByAppendingPathComponent("package.json");
        var packageJson = NSString.stringWithContentsOfFileEncodingError(packageJsonPath, NSUTF8StringEncoding, null);
        if(packageJson) {
          try {
            var mainFile = JSON.parse(packageJson).main || mainFile;
          } catch (e) {
            throw new Error("Failed to normalize module. Error parsing package.json in '" + packageJsonPath + "' - " + e);
          }
        }
        return urlAsNsString.stringByAppendingPathComponent(mainFile);
      } else { // if is file - return the file path
        return url;
      }
    } else {
      var jsFilePath = urlAsNsString.stringByAppendingPathExtension("js");
      if (fileManager.fileExistsAtPathIsDirectory(jsFilePath, isDirectory)) {
        if (isDirectory.value) {
          throw new Error("Failed to normalize module. Expected '" + jsFilePath + "' to be a file.");
        }
        return jsFilePath;
      } else {
          throw new Error("Failed to normalize module '" + url + "'.");
      }
    }
  };
});

/*
  __useDefault
  
  When a module object looks like:
  newModule(
    __useDefault: true,
    default: 'some-module'
  })

  Then importing that module provides the 'some-module'
  result directly instead of the full module.

  Useful for eg module.exports = function() {}
*/
hook('import', function(systemImport) {
  return function(name, parentName, parentAddress) {
    return systemImport.call(this, name, parentName, parentAddress).then(function(module) {
      return module.__useDefault ? module['default'] : module;
    });
  };
});

/*
  NativeScript for iOS specific hook. It fetches modules from the file system.
*/
hook('fetch', function(fetch) {
  var fetchTextFromURL = function(url, fulfill, reject) {
    var moduleSource = NSString.stringWithContentsOfFileEncodingError(url, NSUTF8StringEncoding, null);
    if(moduleSource != null) {
      fulfill(moduleSource.description);
    } else {
      reject("Unable to fetch module with url: " + url);
    }
  }

  return function(load) {
    // Note: We don't call the base fetch method, because this is our base implementation.
    return new Promise(function(resolve, reject) {
      fetchTextFromURL(load.address, resolve, reject);
    });
  };
});

/*
 Extend config merging one deep only

  loader.config({
    some: 'random',
    config: 'here',
    deep: {
      config: { too: 'too' }
    }
  });

  <=>

  loader.some = 'random';
  loader.config = 'here'
  loader.deep = loader.deep || {};
  loader.deep.config = { too: 'too' };


  Normalizes meta and package configs allowing for:

  System.config({
    meta: {
      './index.js': {}
    }
  });

  To become

  System.meta['https://thissite.com/index.js'] = {};

  For easy normalization canonicalization with latest URL support.

*/
SystemJSLoader.prototype.config = function(cfg) {
  for (var c in cfg) {
    var v = cfg[c];
    var normalizeProp = false, normalizeValArray = false;

    if (typeof v == 'object' && !(v instanceof Array)) {
      this[c] = this[c] || {};

      if (c == 'packages' || c == 'meta' || c == 'depCache')
        normalizeProp = true;

      for (var p in v) {
        
        // object map backwards-compat into packages configuration
        if (c == 'map' && typeof v[p] != 'string') {
          var normalized = this.normalizeSync(p);

          // if doing default js extensions, undo to get package name
          if (this.defaultJSExtensions)
            normalized = normalized.substr(0, normalized.length - 3);

          // if a package main, revert it
          var pkgMatch = '';
          for (var pkg in this.packages) {
            if (normalized.substr(0, pkg.length) == pkg 
                && (!normalized[pkg.length] || normalized[pkg.length] == '/') 
                && pkgMatch.split('/').length < pkg.split('/').length)
              pkgMatch = pkg;
          }
          if (pkgMatch && this.packages[pkgMatch].main)
            normalized = normalized.substr(0, normalized.length - this.packages[pkgMatch].main.length - 1);


          var pkg = this.packages[normalized] = this.packages[normalized] || {};
          pkg.map = v[p];
        }

        else if (c == 'bundles') {
          var bundle = [];
          for (var i = 0; i < cfg[c][p].length; i++)
            bundle.push(this.normalizeSync(cfg[c][p][i]));
          this[c][p] = bundle;
        }

        else if (normalizeProp) {
          this[c][this.normalizeSync(p)] = v[p];
        }

        else {
          this[c][p] = v[p];
        }
      }
    }
    else
      this[c] = v;
  }

  // sanitize baseURL
  if (cfg.baseURL)
    getBaseURLObj.call(this);
};

})();/*
 * Script tag fetch
 *
 * When load.metadata.scriptLoad is true, we load via script tag injection.
 */
(function() {

  if (typeof document != 'undefined')
    var head = document.getElementsByTagName('head')[0];

  // call this functione everytime a wrapper executes
  var curSystem;
  // System clobbering protection for Traceur
  SystemJSLoader.prototype.onScriptLoad = function() {
    __global.System = curSystem;
  };

  function webWorkerImport(loader, load) {
    return new Promise(function(resolve, reject) {
      try {
        importScripts(load.address);
      }
      catch(e) {
        reject(e);
      }

      loader.onScriptLoad(load);
      // if nothing registered, then something went wrong
      if (!load.metadata.registered)
        reject(load.address + ' did not call System.register or AMD define');

      resolve('');
    });
  }

  // override fetch to use script injection
  hook('fetch', function(fetch) {
    return function(load) {
      var loader = this;

      if (!load.metadata.scriptLoad || (!isBrowser && !isWorker))
        return fetch.call(this, load);

      if (isWorker)
        return webWorkerImport(loader, load);

      return new Promise(function(resolve, reject) {
        var s = document.createElement('script');
        s.async = true;

        function complete(evt) {
          if (s.readyState && s.readyState != 'loaded' && s.readyState != 'complete')
            return;
          cleanup();

          // this runs synchronously after execution
          // we now need to tell the wrapper handlers that
          // this load record has just executed
          loader.onScriptLoad(load);

          // if nothing registered, then something went wrong
          if (!load.metadata.registered)
            reject(load.address + ' did not call System.register or AMD define');

          resolve('');
        }

        function error(evt) {
          cleanup();
          reject(new Error('Unable to load script ' + load.address));
        }

        if (s.attachEvent) {
          s.attachEvent('onreadystatechange', complete);
        }
        else {
          s.addEventListener('load', complete, false);
          s.addEventListener('error', error, false);
        }

        curSystem = __global.System;
        __global.System = loader;
        s.src = load.address;
        head.appendChild(s);

        function cleanup() {
          if (s.detachEvent)
            s.detachEvent('onreadystatechange', complete);
          else {
            s.removeEventListener('load', complete, false);
            s.removeEventListener('error', error, false);
          }
          head.removeChild(s);
        }
      });
    };
  });
})();
/*
 * Instantiate registry extension
 *
 * Supports Traceur System.register 'instantiate' output for loading ES6 as ES5.
 *
 * - Creates the loader.register function
 * - Also supports metadata.format = 'register' in instantiate for anonymous register modules
 * - Also supports metadata.deps, metadata.execute and metadata.executingRequire
 *     for handling dynamic modules alongside register-transformed ES6 modules
 *
 *
 * The code here replicates the ES6 linking groups algorithm to ensure that
 * circular ES6 compiled into System.register can work alongside circular AMD 
 * and CommonJS, identically to the actual ES6 loader.
 *
 */
(function() {

  /*
   * There are two variations of System.register:
   * 1. System.register for ES6 conversion (2-3 params) - System.register([name, ]deps, declare)
   *    see https://github.com/ModuleLoader/es6-module-loader/wiki/System.register-Explained
   *
   * 2. System.registerDynamic for dynamic modules (3-4 params) - System.registerDynamic([name, ]deps, executingRequire, execute)
   * the true or false statement 
   *
   * this extension implements the linking algorithm for the two variations identical to the spec
   * allowing compiled ES6 circular references to work alongside AMD and CJS circular references.
   *
   */
  var anonRegister;
  var calledRegister;
  function doRegister(loader, name, register) {
    calledRegister = true;

    // named register
    if (name) {
      name = loader.normalizeSync(name);
      register.name = name;
      if (!(name in loader.defined))
        loader.defined[name] = register; 
    }
    // anonymous register
    else if (register.declarative) {
      if (anonRegister)
        throw new TypeError('Multiple anonymous System.register calls in the same module file.');
      anonRegister = register;
    }
  }
  SystemJSLoader.prototype.register = function(name, deps, declare) {
    if (typeof name != 'string') {
      declare = deps;
      deps = name;
      name = null;
    }

    // dynamic backwards-compatibility
    // can be deprecated eventually
    if (typeof declare == 'boolean')
      return this.registerDynamic.apply(this, arguments);

    doRegister(this, name, {
      declarative: true,
      deps: deps,
      declare: declare
    });
  };
  SystemJSLoader.prototype.registerDynamic = function(name, deps, declare, execute) {
    if (typeof name != 'string') {
      execute = declare;
      declare = deps;
      deps = name;
      name = null;
    }

    // dynamic
    doRegister(this, name, {
      declarative: false,
      deps: deps,
      execute: execute,
      executingRequire: declare
    });
  };
  /*
   * Registry side table - loader.defined
   * Registry Entry Contains:
   *    - name
   *    - deps 
   *    - declare for declarative modules
   *    - execute for dynamic modules, different to declarative execute on module
   *    - executingRequire indicates require drives execution for circularity of dynamic modules
   *    - declarative optional boolean indicating which of the above
   *
   * Can preload modules directly on System.defined['my/module'] = { deps, execute, executingRequire }
   *
   * Then the entry gets populated with derived information during processing:
   *    - normalizedDeps derived from deps, created in instantiate
   *    - groupIndex used by group linking algorithm
   *    - evaluated indicating whether evaluation has happend
   *    - module the module record object, containing:
   *      - exports actual module exports
   *
   *    For dynamic we track the es module with:
   *    - esModule actual es module value
   *      
   *    Then for declarative only we track dynamic bindings with the 'module' records:
   *      - name
   *      - exports
   *      - setters declarative setter functions
   *      - dependencies, module records of dependencies
   *      - importers, module records of dependents
   *
   * After linked and evaluated, entries are removed, declarative module records remain in separate
   * module binding table
   *
   */
  hookConstructor(function(constructor) {
    return function() {
      constructor.call(this);

      this.defined = {};
      this._loader.moduleRecords = {};
    };
  });

  // script injection mode calls this function synchronously on load
  hook('onScriptLoad', function(onScriptLoad) {
    return function(load) {
      onScriptLoad.call(this, load);

      // anonymous define
      if (anonRegister)
        load.metadata.entry = anonRegister;
      
      if (calledRegister) {
        load.metadata.format = load.metadata.format || 'register';
        load.metadata.registered = true;
        calledRegister = false;
        anonRegister = null;
      }
    };
  });

  function buildGroups(entry, loader, groups) {
    groups[entry.groupIndex] = groups[entry.groupIndex] || [];

    if (indexOf.call(groups[entry.groupIndex], entry) != -1)
      return;

    groups[entry.groupIndex].push(entry);

    for (var i = 0, l = entry.normalizedDeps.length; i < l; i++) {
      var depName = entry.normalizedDeps[i];
      var depEntry = loader.defined[depName];
      
      // not in the registry means already linked / ES6
      if (!depEntry || depEntry.evaluated)
        continue;
      
      // now we know the entry is in our unlinked linkage group
      var depGroupIndex = entry.groupIndex + (depEntry.declarative != entry.declarative);

      // the group index of an entry is always the maximum
      if (depEntry.groupIndex === undefined || depEntry.groupIndex < depGroupIndex) {
        
        // if already in a group, remove from the old group
        if (depEntry.groupIndex !== undefined) {
          groups[depEntry.groupIndex].splice(indexOf.call(groups[depEntry.groupIndex], depEntry), 1);

          // if the old group is empty, then we have a mixed depndency cycle
          if (groups[depEntry.groupIndex].length == 0)
            throw new TypeError("Mixed dependency cycle detected");
        }

        depEntry.groupIndex = depGroupIndex;
      }

      buildGroups(depEntry, loader, groups);
    }
  }

  function link(name, loader) {
    var startEntry = loader.defined[name];

    // skip if already linked
    if (startEntry.module)
      return;

    startEntry.groupIndex = 0;

    var groups = [];

    buildGroups(startEntry, loader, groups);

    var curGroupDeclarative = !!startEntry.declarative == groups.length % 2;
    for (var i = groups.length - 1; i >= 0; i--) {
      var group = groups[i];
      for (var j = 0; j < group.length; j++) {
        var entry = group[j];

        // link each group
        if (curGroupDeclarative)
          linkDeclarativeModule(entry, loader);
        else
          linkDynamicModule(entry, loader);
      }
      curGroupDeclarative = !curGroupDeclarative; 
    }
  }

  // module binding records
  function getOrCreateModuleRecord(name, moduleRecords) {
    return moduleRecords[name] || (moduleRecords[name] = {
      name: name,
      dependencies: [],
      exports: {}, // start from an empty module and extend
      importers: []
    });
  }

  function linkDeclarativeModule(entry, loader) {
    // only link if already not already started linking (stops at circular)
    if (entry.module)
      return;

    var moduleRecords = loader._loader.moduleRecords;
    var module = entry.module = getOrCreateModuleRecord(entry.name, moduleRecords);
    var exports = entry.module.exports;

    var declaration = entry.declare.call(__global, function(name, value) {
      module.locked = true;
      exports[name] = value;

      for (var i = 0, l = module.importers.length; i < l; i++) {
        var importerModule = module.importers[i];
        if (!importerModule.locked) {
          var importerIndex = indexOf.call(importerModule.dependencies, module);
          importerModule.setters[importerIndex](exports);
        }
      }

      module.locked = false;
      return value;
    });
    
    module.setters = declaration.setters;
    module.execute = declaration.execute;

    if (!module.setters || !module.execute) {
      throw new TypeError('Invalid System.register form for ' + entry.name);
    }

    // now link all the module dependencies
    for (var i = 0, l = entry.normalizedDeps.length; i < l; i++) {
      var depName = entry.normalizedDeps[i];
      var depEntry = loader.defined[depName];
      var depModule = moduleRecords[depName];

      // work out how to set depExports based on scenarios...
      var depExports;

      if (depModule) {
        depExports = depModule.exports;
      }
      // dynamic, already linked in our registry
      else if (depEntry && !depEntry.declarative) {
        depExports = depEntry.esModule;
      }
      // in the loader registry
      else if (!depEntry) {
        depExports = loader.get(depName);
      }
      // we have an entry -> link
      else {
        linkDeclarativeModule(depEntry, loader);
        depModule = depEntry.module;
        depExports = depModule.exports;
      }

      // only declarative modules have dynamic bindings
      if (depModule && depModule.importers) {
        depModule.importers.push(module);
        module.dependencies.push(depModule);
      }
      else {
        module.dependencies.push(null);
      }

      // run the setter for this dependency
      if (module.setters[i])
        module.setters[i](depExports);
    }
  }

  // An analog to loader.get covering execution of all three layers (real declarative, simulated declarative, simulated dynamic)
  function getModule(name, loader) {
    var exports;
    var entry = loader.defined[name];

    if (!entry) {
      exports = loader.get(name);
      if (!exports)
        throw new Error('Unable to load dependency ' + name + '.');
    }

    else {
      if (entry.declarative)
        ensureEvaluated(name, [], loader);
    
      else if (!entry.evaluated)
        linkDynamicModule(entry, loader);

      exports = entry.module.exports;
    }

    if ((!entry || entry.declarative) && exports && exports.__useDefault)
      return exports['default'];
    
    return exports;
  }

  function linkDynamicModule(entry, loader) {
    if (entry.module)
      return;

    var exports = {};

    var module = entry.module = { exports: exports, id: entry.name };

    // AMD requires execute the tree first
    if (!entry.executingRequire) {
      for (var i = 0, l = entry.normalizedDeps.length; i < l; i++) {
        var depName = entry.normalizedDeps[i];
        // we know we only need to link dynamic due to linking algorithm
        var depEntry = loader.defined[depName];
        if (depEntry)
          linkDynamicModule(depEntry, loader);
      }
    }

    // now execute
    entry.evaluated = true;
    var output = entry.execute.call(__global, function(name) {
      for (var i = 0, l = entry.deps.length; i < l; i++) {
        if (entry.deps[i] != name)
          continue;
        return getModule(entry.normalizedDeps[i], loader);
      }

      var moduleExports;
      var error;
      var shouldRun = true;
      System.import(name, entry.name).then(function(m) {
        shouldRun = false;
        moduleExports = m;
      }, function(e) {
        shouldRun = false;
        error = e;
      });
      var runLoopMode = NSString.stringWithString(kCFRunLoopDefaultMode);
      while(shouldRun) {
        CFRunLoopRunInMode(runLoopMode, 0.1, false);
      }
      if(error) {
        throw error;
      }
      else {
        return moduleExports;
      }
    }, exports, module);


    
    if (output)
      module.exports = output;

    // create the esModule object, which allows ES6 named imports of dynamics
    exports = module.exports;

    if (exports && exports.__esModule) {
      entry.esModule = exports;
    }
    else {
      var hasOwnProperty = exports && exports.hasOwnProperty;
      entry.esModule = {};
      for (var p in exports) {
        if (!hasOwnProperty || exports.hasOwnProperty(p))
          entry.esModule[p] = exports[p];
      }
      entry.esModule['default'] = exports;
      entry.esModule.__useDefault = true;
    }
  }

  /*
   * Given a module, and the list of modules for this current branch,
   *  ensure that each of the dependencies of this module is evaluated
   *  (unless one is a circular dependency already in the list of seen
   *  modules, in which case we execute it)
   *
   * Then we evaluate the module itself depth-first left to right 
   * execution to match ES6 modules
   */
  function ensureEvaluated(moduleName, seen, loader) {
    var entry = loader.defined[moduleName];

    // if already seen, that means it's an already-evaluated non circular dependency
    if (!entry || entry.evaluated || !entry.declarative)
      return;

    // this only applies to declarative modules which late-execute

    seen.push(moduleName);

    for (var i = 0, l = entry.normalizedDeps.length; i < l; i++) {
      var depName = entry.normalizedDeps[i];
      if (indexOf.call(seen, depName) == -1) {
        if (!loader.defined[depName])
          loader.get(depName);
        else
          ensureEvaluated(depName, seen, loader);
      }
    }

    if (entry.evaluated)
      return;

    entry.evaluated = true;
    entry.module.execute.call(__global);
  }

  // override the delete method to also clear the register caches
  hook('delete', function(del) {
    return function(name) {
      delete this._loader.moduleRecords[name];
      delete this.defined[name];
      return del.call(this, name);
    };
  });

  var registerRegEx = /^\s*(\/\*.*\*\/\s*|\/\/[^\n]*\s*)*System\.register(Dyanmic)?\s*\(/;

  hook('fetch', function(fetch) {
    return function(load) {
      if (this.defined[load.name]) {
        load.metadata.format = 'defined';
        return '';
      }
      
      // this is the synchronous chain for onScriptLoad
      anonRegister = null;
      calledRegister = false;
      
      if (load.metadata.format == 'register')
        load.metadata.scriptLoad = true;
      
      return fetch.call(this, load);
    };
  });

  hook('translate', function(translate) {
    // we run the meta detection here (register is after meta)
    return function(load) {
      return Promise.resolve(translate.call(this, load)).then(function(source) {

        if (typeof load.metadata.deps === 'string')
          load.metadata.deps = load.metadata.deps.split(',');
        load.metadata.deps = load.metadata.deps || [];

        // run detection for register format
        if (load.metadata.format == 'register' || !load.metadata.format && load.source.match(registerRegEx))
          load.metadata.format = 'register';
        return source;
      });
    };
  });

  hook('instantiate', function(instantiate) {
    return function(load) {
      var loader = this;

      var entry;

      // first we check if this module has already been defined in the registry
      if (loader.defined[load.name]) {
        entry = loader.defined[load.name];
        entry.deps = entry.deps.concat(load.metadata.deps);
      }

      // picked up already by a script injection
      else if (load.metadata.entry)
        entry = load.metadata.entry;

      // otherwise check if it is dynamic
      else if (load.metadata.execute) {
        entry = {
          declarative: false,
          deps: load.metadata.deps || [],
          execute: load.metadata.execute,
          executingRequire: load.metadata.executingRequire // NodeJS-style requires or not
        };
      }

      // Contains System.register calls
      else if (load.metadata.format == 'register' || load.metadata.format == 'esm' || load.metadata.format == 'es6') {
        anonRegister = null;
        calledRegister = false;

        __exec.call(loader, load);

        if (anonRegister)
          entry = anonRegister;
        else
          load.metadata.bundle = true;

        if (!entry && loader.defined[load.name])
          entry = loader.defined[load.name];

        if (!calledRegister && !load.metadata.registered)
          throw new TypeError(load.name + ' detected as System.register but didn\'t execute.');
      }

      // named bundles are just an empty module
      if (!entry)
        return {
          deps: load.metadata.deps,
          execute: function() {
            return loader.newModule({});
          }
        };

      // place this module onto defined for circular references
      if (entry)
        loader.defined[load.name] = entry;

      // no entry -> treat as ES6
      else
        return instantiate.call(loader, load);

      entry.deps = dedupe(entry.deps);
      entry.name = load.name;

      // first, normalize all dependencies
      var normalizePromises = [];
      for (var i = 0, l = entry.deps.length; i < l; i++)
        normalizePromises.push(Promise.resolve(loader.normalize(entry.deps[i], load.name)));

      return Promise.all(normalizePromises).then(function(normalizedDeps) {

        entry.normalizedDeps = normalizedDeps;

        return {
          deps: entry.deps,
          execute: function() {
            // recursively ensure that the module and all its 
            // dependencies are linked (with dependency group handling)
            link(load.name, loader);

            // now handle dependency execution in correct order
            ensureEvaluated(load.name, [], loader);

            // remove from the registry
            loader.defined[load.name] = undefined;

            // return the defined module object
            return loader.newModule(entry.declarative ? entry.module.exports : entry.esModule);
          }
        };
      });
    };
  });
})();
/*
 * Extension to detect ES6 and auto-load Traceur or Babel for processing
 */
(function() {
  // good enough ES6 module detection regex - format detections not designed to be accurate, but to handle the 99% use case
  var esmRegEx = /(^\s*|[}\);\n]\s*)(import\s+(['"]|(\*\s+as\s+)?[^"'\(\)\n;]+\s+from\s+['"]|\{)|export\s+\*\s+from\s+["']|export\s+(\{|default|function|class|var|const|let|async\s+function))/;

  var traceurRuntimeRegEx = /\$traceurRuntime\s*\./;
  var babelHelpersRegEx = /babelHelpers\s*\./;

  hook('translate', function(translate) {
    return function(load) {
      var loader = this;
      return translate.call(loader, load)
      .then(function(source) {
        // detect & transpile ES6
        if (load.metadata.format == 'esm' || load.metadata.format == 'es6' || !load.metadata.format && source.match(esmRegEx)) {
          load.metadata.format = 'esm';

          // setting _loadedTranspiler = false tells the next block to
          // do checks for setting transpiler metadata
          this._loadedTranspiler = this._loadedTranspiler || false;

          // defined in es6-module-loader/src/transpile.js
          return transpile.call(loader, load);
        }

        // load the transpiler correctly
        if (this._loadedTranspiler === false && load.name == loader.normalizeSync(loader.transpiler)) {
          // always load transpiler as a global
          if (source.length > 100) {
            load.metadata.format = load.metadata.format || 'global';

            if (loader.transpiler === 'traceur')
              load.metadata.exports = 'traceur';
            if (loader.transpiler === 'typescript')
              load.metadata.exports = 'ts';
          }
        }

        if (load.metadata.format == 'register') {
          if (!__global.$traceurRuntime && load.source.match(traceurRuntimeRegEx)) {
            loader.meta[loader.normalizeSync('traceur-runtime')] = {format: 'global'};
            return loader['import']('traceur-runtime').then(function() {
              return source;
            });
          }
          if (!__global.babelHelpers && load.source.match(babelHelpersRegEx)) {
            loader.meta[loader.normalizeSync('babel/external-helpers*')] = {format: 'global'};
            return loader['import']('babel/external-helpers').then(function() {
              return source;
            });
          }
        }

        return source;
      });
    };
  });

})();
/*
  SystemJS Global Format

  Supports
    metadata.deps
    metadata.globals
    metadata.exports

  Without metadata.exports, detects writes to the global object.
*/
var __globalName = typeof self != 'undefined' ? 'self' : 'global';

hook('onScriptLoad', function(onScriptLoad) {
  return function(load) {
    if (load.metadata.format == 'global') {
      load.metadata.registered = true;
      var globalValue = readMemberExpression(load.metadata.exports, __global);
      load.metadata.execute = function() {
        return globalValue;
      }
    }
    return onScriptLoad.call(this, load);
  };
});

hook('fetch', function(fetch) {
  return function(load) {
    if (load.metadata.exports)
      load.metadata.format = 'global';

    // A global with exports, no globals and no deps
    // can be loaded via a script tag
    if (load.metadata.format == 'global' 
        && load.metadata.exports && !load.metadata.globals 
        && (!load.metadata.deps || load.metadata.deps.length == 0))
      load.metadata.scriptLoad = true;

    return fetch.call(this, load);
  };
});

// ideally we could support script loading for globals, but the issue with that is that
// we can't do it with AMD support side-by-side since AMD support means defining the
// global define, and global support means not definining it, yet we don't have any hook
// into the "pre-execution" phase of a script tag being loaded to handle both cases


hook('instantiate', function(instantiate) {
  return function(load) {
    var loader = this;

    if (!load.metadata.format)
      load.metadata.format = 'global';

    // add globals as dependencies
    if (load.metadata.globals)
      for (var g in load.metadata.globals)
        load.metadata.deps.push(load.metadata.globals[g]);

    // global is a fallback module format
    if (load.metadata.format == 'global' && !load.metadata.registered) {
      load.metadata.execute = function(require, exports, module) {

        var globals;
        if (load.metadata.globals) {
          globals = {};
          for (var g in load.metadata.globals)
            globals[g] = require(load.metadata.globals[g]);
        }
        
        var exportName = load.metadata.exports;
        var retrieveGlobal = loader.get('@@global-helpers').prepareGlobal(module.id, exportName, globals);

        if (exportName)
          load.source += '\n' + __globalName + '["' + exportName + '"] = ' + exportName + ';';

        // disable module detection
        var define = __global.define;
        var cRequire = __global.require;
        
        __global.define = undefined;
        __global.module = undefined;
        __global.exports = undefined;

        __exec.call(loader, load);

        __global.require = cRequire;
        __global.define = define;

        return retrieveGlobal();
      }
    }
    return instantiate.call(this, load);
  };
});
hookConstructor(function(constructor) {
  return function() {
    var loader = this;
    constructor.call(loader);

    var hasOwnProperty = Object.prototype.hasOwnProperty;

    // bare minimum ignores for IE8
    var ignoredGlobalProps = ['_g', 'sessionStorage', 'localStorage', 'clipboardData', 'frames', 'external'];

    var globalSnapshot;

    function forEachGlobal(callback) {
      if (Object.keys)
        Object.keys(__global).forEach(callback);
      else
        for (var g in __global) {
          if (!hasOwnProperty.call(__global, g))
            continue;
          callback(g);
        }
    }

    function forEachGlobalValue(callback) {
      forEachGlobal(function(globalName) {
        if (indexOf.call(ignoredGlobalProps, globalName) != -1)
          return;
        try {
          var value = __global[globalName];
        }
        catch (e) {
          ignoredGlobalProps.push(globalName);
        }
        callback(globalName, value);
      });
    }

    loader.set('@@global-helpers', loader.newModule({
      prepareGlobal: function(moduleName, exportName, globals) {
        // set globals
        var oldGlobals;
        if (globals) {
          oldGlobals = {};
          for (var g in globals) {
            oldGlobals[g] = globals[g];
            __global[g] = globals[g];
          }
        }

        // store a complete copy of the global object in order to detect changes
        if (!exportName) {
          globalSnapshot = {};

          forEachGlobalValue(function(name, value) {
            globalSnapshot[name] = value;
          });
        }

        // return function to retrieve global
        return function() {
          var globalValue;

          if (exportName) {
            globalValue = readMemberExpression(exportName, __global);
          }
          else {
            var singleGlobal;
            var multipleExports;
            var exports = {};

            forEachGlobalValue(function(name, value) {
              if (globalSnapshot[name] === value)
                return;
              if (typeof value == 'undefined')
                return;
              exports[name] = value;

              if (typeof singleGlobal != 'undefined') {
                if (!multipleExports && singleGlobal !== value)
                  multipleExports = true;
              }
              else {
                singleGlobal = value;
              }
            });
            globalValue = multipleExports ? exports : singleGlobal;
          }

          // revert globals
          if (oldGlobals) {
            for (var g in oldGlobals)
              __global[g] = oldGlobals[g];
          }

          return globalValue;
        };
      }
    }));
  };
});/*
  SystemJS CommonJS Format
*/
(function() {
  // CJS Module Format
  // require('...') || exports[''] = ... || exports.asd = ... || module.exports = ...
  var cjsExportsRegEx = /(?:^\uFEFF?|[^$_a-zA-Z\xA0-\uFFFF.]|module\.)exports\s*(\[['"]|\.)|(?:^\uFEFF?|[^$_a-zA-Z\xA0-\uFFFF.])module\.exports\s*[=,]/;
  // RegEx adjusted from https://github.com/jbrantly/yabble/blob/master/lib/yabble.js#L339
  var cjsRequireRegEx = /(?:^\uFEFF?|[^$_a-zA-Z\xA0-\uFFFF."'])require\s*\(\s*("[^"\\]*(?:\\.[^"\\]*)*"|'[^'\\]*(?:\\.[^'\\]*)*')\s*\)/g;

  if (typeof window != 'undefined' && window.location)
    var windowOrigin = location.protocol + '//' + location.hostname + (location.port ? ':' + location.port : '');

  hookConstructor(function(constructor) {
    return function() {
      constructor.call(this);

      // include the node require since we're overriding it
      if (typeof require != 'undefined' && require.resolve && typeof process != 'undefined')
        this._nodeRequire = require;
    };
  });

  hook('instantiate', function(instantiate) {
    return function(load) {
      var loader = this;
      if (!load.metadata.format) {
        cjsExportsRegEx.lastIndex = 0;
        cjsRequireRegEx.lastIndex = 0;
        if (cjsRequireRegEx.exec(load.source) || cjsExportsRegEx.exec(load.source))
          load.metadata.format = 'cjs';
      }

      if (load.metadata.format == 'cjs') {
        var metaDeps = load.metadata.deps || [];

        load.metadata.executingRequire = true;

        load.metadata.execute = function(require, exports, module) {
          // ensure meta deps execute first
          for (var i = 0; i < metaDeps.length; i++)
            require(metaDeps[i]);
          var address = load.address || '';

          var dirname = address.split('/');
          dirname.pop();
          dirname = dirname.join('/');

          if (windowOrigin && address.substr(0, windowOrigin.length) === windowOrigin) {
            address = address.substr(windowOrigin.length);
            dirname = dirname.substr(windowOrigin.length);
          }
          else if (address.substr(0, 8) == 'file:///') {
            address = address.substr(8);
            dirname = dirname.substr(8);
          }

          // disable AMD detection
          var define = __global.define;
          __global.define = undefined;

          __global.__cjsWrapper = {
            exports: exports,
            args: [require, exports, module, address, dirname, __global]
          };

          load.source = "(function(require, exports, module, __filename, __dirname, global) {"
              + load.source + "\n}).apply(__cjsWrapper.exports, __cjsWrapper.args);";

          __exec.call(loader, load);

          __global.__cjsWrapper = undefined;
          __global.define = define;
        };
      }

      return instantiate.call(loader, load);
    };
  });
})();
/*
 * AMD Helper function module
 * Separated into its own file as this is the part needed for full AMD support in SFX builds
 *
 */
hookConstructor(function(constructor) {
  return function() {
    var loader = this;
    constructor.call(this);

    var commentRegEx = /(\/\*([\s\S]*?)\*\/|([^:]|^)\/\/(.*)$)/mg;
    var cjsRequirePre = "(?:^|[^$_a-zA-Z\\xA0-\\uFFFF.])";
    var cjsRequirePost = "\\s*\\(\\s*(\"([^\"]+)\"|'([^']+)')\\s*\\)";
    var fnBracketRegEx = /\(([^\)]*)\)/;
    var wsRegEx = /^\s+|\s+$/g;
    
    var requireRegExs = {};

    function getCJSDeps(source, requireIndex) {

      // remove comments
      source = source.replace(commentRegEx, '');

      // determine the require alias
      var params = source.match(fnBracketRegEx);
      var requireAlias = (params[1].split(',')[requireIndex] || 'require').replace(wsRegEx, '');

      // find or generate the regex for this requireAlias
      var requireRegEx = requireRegExs[requireAlias] || (requireRegExs[requireAlias] = new RegExp(cjsRequirePre + requireAlias + cjsRequirePost, 'g'));

      requireRegEx.lastIndex = 0;

      var deps = [];

      var match;
      while (match = requireRegEx.exec(source))
        deps.push(match[2] || match[3]);

      return deps;
    }

    /*
      AMD-compatible require
      To copy RequireJS, set window.require = window.requirejs = loader.amdRequire
    */
    function require(names, callback, errback, referer) {
      // in amd, first arg can be a config object... we just ignore
      if (typeof names == 'object' && !(names instanceof Array))
        return require.apply(null, Array.prototype.splice.call(arguments, 1, arguments.length - 1));

      // amd require
      if (typeof names == 'string' && typeof callback == 'function')
        names = [names];
      if (names instanceof Array) {
        var dynamicRequires = [];
        for (var i = 0; i < names.length; i++)
          dynamicRequires.push(loader['import'](names[i], referer));
        Promise.all(dynamicRequires).then(function(modules) {
          if (callback)
            callback.apply(null, modules);
        }, errback);
      }

      // commonjs require
      else if (typeof names == 'string') {
        var module = loader.get(names);
        return module.__useDefault ? module['default'] : module;
      }

      else
        throw new TypeError('Invalid require');
    };

    function define(name, deps, factory) {
      if (typeof name != 'string') {
        factory = deps;
        deps = name;
        name = null;
      }
      if (!(deps instanceof Array)) {
        factory = deps;
        deps = ['require', 'exports', 'module'].splice(0, factory.length);
      }

      if (typeof factory != 'function')
        factory = (function(factory) {
          return function() { return factory; }
        })(factory);

      // in IE8, a trailing comma becomes a trailing undefined entry
      if (deps[deps.length - 1] === undefined)
        deps.pop();

      // remove system dependencies
      var requireIndex, exportsIndex, moduleIndex;
      
      if ((requireIndex = indexOf.call(deps, 'require')) != -1) {
        
        deps.splice(requireIndex, 1);

        // only trace cjs requires for non-named
        // named defines assume the trace has already been done
        if (!name)
          deps = deps.concat(getCJSDeps(factory.toString(), requireIndex));
      }

      if ((exportsIndex = indexOf.call(deps, 'exports')) != -1)
        deps.splice(exportsIndex, 1);
      
      if ((moduleIndex = indexOf.call(deps, 'module')) != -1)
        deps.splice(moduleIndex, 1);

      var define = {
        name: name,
        deps: deps,
        execute: function(req, exports, module) {

          var depValues = [];
          for (var i = 0; i < deps.length; i++)
            depValues.push(req(deps[i]));

          module.uri = loader.baseURL + (module.id[0] == '/' ? module.id : '/' + module.id);

          module.config = function() {};

          // add back in system dependencies
          if (moduleIndex != -1)
            depValues.splice(moduleIndex, 0, module);
          
          if (exportsIndex != -1)
            depValues.splice(exportsIndex, 0, exports);
          
          if (requireIndex != -1) 
            depValues.splice(requireIndex, 0, function(names, callback, errback) {
              if (typeof names == 'string' && typeof callback != 'function')
                return req(names);
              return require.call(loader, names, callback, errback, module.id);
            });

          // set global require to AMD require
          var curRequire = __global.require;
          __global.require = require;

          var output = factory.apply(exportsIndex == -1 ? __global : exports, depValues);

          __global.require = curRequire;

          if (typeof output == 'undefined' && module)
            output = module.exports;

          if (typeof output != 'undefined')
            return output;
        }
      };

      // anonymous define
      if (!name) {
        // already defined anonymously -> throw
        if (lastModule.anonDefine)
          throw new TypeError('Multiple defines for anonymous module');
        lastModule.anonDefine = define;
      }
      // named define
      else {
        // if it has no dependencies and we don't have any other
        // defines, then let this be an anonymous define
        // this is just to support single modules of the form:
        // define('jquery')
        // still loading anonymously
        // because it is done widely enough to be useful
        if (deps.length == 0 && !lastModule.anonDefine && !lastModule.isBundle) {
          lastModule.anonDefine = define;
        }
        // otherwise its a bundle only
        else {
          // if there is an anonDefine already (we thought it could have had a single named define)
          // then we define it now
          // this is to avoid defining named defines when they are actually anonymous
          if (lastModule.anonDefine && lastModule.anonDefine.name)
            loader.registerDynamic(lastModule.anonDefine.name, lastModule.anonDefine.deps, false, lastModule.anonDefine.execute);

          lastModule.anonDefine = null;
        }

        // note this is now a bundle
        lastModule.isBundle = true;

        // define the module through the register registry
        loader.registerDynamic(name, define.deps, false, define.execute);
      }
    }
    define.amd = {};

    // adds define as a global (potentially just temporarily)
    function createDefine(loader) {
      lastModule.anonDefine = null;
      lastModule.isBundle = false;

      // ensure no NodeJS environment detection
      var oldModule = __global.module;
      var oldExports = __global.exports;
      var oldDefine = __global.define;

      __global.module = undefined;
      __global.exports = undefined;
      __global.define = define;

      return function() {
        __global.define = oldDefine;
        __global.module = oldModule;
        __global.exports = oldExports;
      };
    }

    var lastModule = {
      isBundle: false,
      anonDefine: null
    };

    loader.set('@@amd-helpers', loader.newModule({
      createDefine: createDefine,
      require: require,
      define: define,
      lastModule: lastModule
    }));
    loader.amdDefine = define;
    loader.amdRequire = require;
  };
});/*
  SystemJS AMD Format
  Provides the AMD module format definition at System.format.amd
  as well as a RequireJS-style require on System.require
*/
(function() {
  // AMD Module Format Detection RegEx
  // define([.., .., ..], ...)
  // define(varName); || define(function(require, exports) {}); || define({})
  var amdRegEx = /(?:^\uFEFF?|[^$_a-zA-Z\xA0-\uFFFF.])define\s*\(\s*("[^"]+"\s*,\s*|'[^']+'\s*,\s*)?\s*(\[(\s*(("[^"]+"|'[^']+')\s*,|\/\/.*\r?\n|\/\*(.|\s)*?\*\/))*(\s*("[^"]+"|'[^']+')\s*,?)?(\s*(\/\/.*\r?\n|\/\*(.|\s)*?\*\/))*\s*\]|function\s*|{|[_$a-zA-Z\xA0-\uFFFF][_$a-zA-Z0-9\xA0-\uFFFF]*\))/;

  // script injection mode calls this function synchronously on load
  hook('onScriptLoad', function(onScriptLoad) {
    return function(load) {
      onScriptLoad.call(this, load);

      var lastModule = this.get('@@amd-helpers').lastModule;
      if (lastModule.anonDefine || lastModule.isBundle) {
        load.metadata.format = 'defined';
        load.metadata.registered = true;
        lastModule.isBundle = false;
      }

      if (lastModule.anonDefine) {
        load.metadata.deps = load.metadata.deps ? load.metadata.deps.concat(lastModule.anonDefine.deps) : lastModule.anonDefine.deps;
        load.metadata.execute = lastModule.anonDefine.execute;
        lastModule.anonDefine = null;
      }
    };
  });

  hook('fetch', function(fetch) {
    return function(load) {
      if (load.metadata.format === 'amd')
        load.metadata.scriptLoad = true;
      if (load.metadata.scriptLoad)
        this.get('@@amd-helpers').createDefine(this);
      return fetch.call(this, load);
    };
  });

  hook('instantiate', function(instantiate) {
    return function(load) {
      var loader = this;
      
      if (load.metadata.format == 'amd' || !load.metadata.format && load.source.match(amdRegEx)) {
        load.metadata.format = 'amd';
        
        if (loader.execute !== false) {
          var removeDefine = this.get('@@amd-helpers').createDefine(loader);

          __exec.call(loader, load);

          removeDefine(loader);

          var lastModule = this.get('@@amd-helpers').lastModule;

          if (!lastModule.anonDefine && !lastModule.isBundle)
            throw new TypeError('AMD module ' + load.name + ' did not define');

          if (lastModule.anonDefine) {
            load.metadata.deps = load.metadata.deps ? load.metadata.deps.concat(lastModule.anonDefine.deps) : lastModule.anonDefine.deps;
            load.metadata.execute = lastModule.anonDefine.execute;
          }

          lastModule.isBundle = false;
          lastModule.anonDefine = null;
        }

        return instantiate.call(loader, load);
      }

      return instantiate.call(loader, load);
    };
  });

})();
/*
  SystemJS map support
  
  Provides map configuration through
    System.map['jquery'] = 'some/module/map'

  Note that this applies for subpaths, just like RequireJS:

  jquery      -> 'some/module/map'
  jquery/path -> 'some/module/map/path'
  bootstrap   -> 'bootstrap'

  The most specific map is always taken, as longest path length
*/
hookConstructor(function(constructor) {
  return function() {
    constructor.call(this);
    this.map = {};
  };
});

hook('normalize', function(normalize) {
  return function(name, parentName, parentAddress) {
    if (name.substr(0, 1) != '.' && name.substr(0, 1) != '/' && !name.match(absURLRegEx)) {
      var bestMatch, bestMatchLength = 0;

      // now do the global map
      for (var p in this.map) {
        if (name.substr(0, p.length) == p && (name.length == p.length || name[p.length] == '/')) {
          var curMatchLength = p.split('/').length;
          if (curMatchLength <= bestMatchLength)
            continue;
          bestMatch = p;
          bestMatchLength = curMatchLength;
        }
      }

      if (bestMatch)
        name = this.map[bestMatch] + name.substr(bestMatch.length);
    }
    
    return normalize.call(this, name, parentName, parentAddress);
  };
});
/*
 * Paths extension
 * 
 * Applies paths and normalizes to a full URL
 */
hook('normalize', function(normalize) {
  return function(name, parentName) {
    var normalized = normalize.call(this, name, parentName);

    // if the module is in the registry already, use that
    if (this.has(normalized))
      return normalized;

    // automatic js extension adding for backwards compatibility
    if (this.defaultJSExtensions && normalized.substr(normalized.length - 3, 3) != '.js')
      normalized += '.js';

    if (normalized.match(absURLRegEx))
      return normalized;

    // applyPaths implementation provided from ModuleLoader system.js source
    normalized = applyPaths(this, normalized) || normalized;

    // ./x, /x -> page-relative
    if (normalized[0] == '.' || normalized[0] == '/')
      return new URL(normalized, baseURIObj).href;
    // x -> baseURL-relative
    else
      return new URL(normalized, getBaseURLObj.call(this)).href;
  };
});/*
 * Package Configuration Extension
 *
 * Example:
 *
 * System.packages = {
 *   jquery: {
 *     main: 'index.js', // when not set, package name is requested directly
 *     format: 'amd',
 *     defaultExtension: true,
 *     meta: {
 *       '*.ts': {
 *         loader: 'typescript'
 *       },
 *       'vendor/sizzle.js': {
 *         format: 'global'
 *       }
 *     },
 *     map: {
 *        // map internal require('sizzle') to local require('./vendor/sizzle')
 *        sizzle: './vendor/sizzle.js',
 *
 *        // map any internal or external require of 'jquery/vendor/another' to 'another/index.js'
 *        './vendor/another': 'another/index.js'
 *      }
 *    }
 *  }
 * };
 *
 * Then:
 *   import 'jquery'                       -> jquery/index.js
 *   import 'jquery/submodule'             -> jquery/submodule.js
 *   import 'jquery/submodule.ts'          -> jquery/submodule.ts loaded as typescript
 *   import 'jquery/vendor/another'        -> another/index.js
 *
 * Detailed Behaviours
 * - main is the only property where a leading "./" can be added optionally
 * - map and defaultExtension are applied to the main
 * - defaultExtension adds the extension only if no other extension is present
 * - if a map or meta value is available for a module without defaultExtension, defaultExtension is skipped
 * - like global map, package map also applies to subpaths (sizzle/x, ./vendor/another/sub)
 * - map targets do not pass through any further map or defaultExtension
 *
 * In addition, the following meta properties will be allowed to be package
 * -relative as well in the package meta config:
 *   
 *   - loader
 *   - alias
 *
 */
(function() {

  hookConstructor(function(constructor) {
    return function() {
      constructor.call(this);
      this.packages = {};
    };
  });

  function getPackage(name) {
    for (var p in this.packages) {
      if (name.substr(0, p.length) === p && (name.length === p.length || name[p.length] === '/'))
        return p;
    }
  }

  function applyMap(map, name) {
    var bestMatch, bestMatchLength = 0;
    
    for (var p in map) {
      if (name.substr(0, p.length) == p && (name.length == p.length || name[p.length] == '/')) {
        var curMatchLength = p.split('/').length;
        if (curMatchLength <= bestMatchLength)
          continue;
        bestMatch = p;
        bestMatchLength = curMatchLength;
      }
    }
    if (bestMatch)
      return map[bestMatch] + name.substr(bestMatch.length);
  }

  hook('normalize', function(normalize) {
    return function(name, parentName) {
      // apply contextual package map first
      if (parentName)
        var parentPackage = getPackage.call(this, parentName);

      if (parentPackage && name[0] !== '.') {
        var parentMap = this.packages[parentPackage].map;
        if (parentMap) {
          name = applyMap(parentMap, name) || name;

          // relative maps are package-relative
          if (name[0] === '.')
            parentName = parentPackage + '/';
        }
      }

      // apply global map, relative normalization
      var normalized = normalize.call(this, name, parentName);

      // check if we are inside a package
      var pkgName = getPackage.call(this, normalized);

      if (pkgName) {
        var pkg = this.packages[pkgName];

        // main
        if (pkgName === normalized) {

          // no package main -> just use package itself
          if (!pkg.main)
            return normalized;

          normalized += '/' + (pkg.main.substr(0, 2) == './' ? pkg.main.substr(2) : pkg.main);
        }

        var defaultExtension;
        if (pkg.defaultExtension && normalized.split('/').pop().indexOf('.') == -1)
          defaultExtension = '.' + pkg.defaultExtension;

        // apply map checking without then with defaultExtension
        var subPath = '.' + normalized.substr(pkgName.length);
        var mapped = applyMap(pkg.map, subPath) || defaultExtension && applyMap(pkg.map, subPath + defaultExtension);
        if (mapped)
          normalized = mapped.substr(0, 2) == './' ? pkgName + mapped.substr(1) : mapped;

        // apply default extension if not in meta and not the package itself
        else if (defaultExtension && (!pkg.meta || !pkg.meta[subPath.substr(2)]))
          normalized += defaultExtension;
      }

      return normalized;
    };
  });

  hook('locate', function(locate) {
    return function(load) {
      var loader = this;
      return Promise.resolve(locate.call(this, load))
      .then(function(address) {
        var pkgName = getPackage.call(loader, load.name);
        if (pkgName) {
          var pkg = loader.packages[pkgName];
          
          // format
          if (pkg.format)
            load.metadata.format = load.metadata.format || pkg.format;

          // loader
          if (pkg.loader)
            load.metadata.loader = load.metadata.loader || pkg.loader;

          if (pkg.meta) {
            // wildcard meta
            var meta = {};
            var bestDepth = 0;
            var wildcardIndex;
            for (var module in pkg.meta) {
              wildcardIndex = module.indexOf('*');
              if (wildcardIndex === -1)
                continue;
              if (module.substr(0, wildcardIndex) === load.name.substr(0, wildcardIndex)
                  && module.substr(wildcardIndex + 1) === load.name.substr(load.name.length - module.length + wildcardIndex + 1)) {
                var depth = module.split('/').length;
                if (depth > bestDepth)
                  bestDetph = depth;
                extend(meta, pkg.meta[module], bestDepth != depth);
              }
            }
            // exact meta
            var exactMeta = pkg.meta[load.name.substr(pkgName.length + 1)];
            if (exactMeta)
              extend(meta, exactMeta);

            // allow alias and loader to be package-relative
            if (meta.alias && meta.alias.substr(0, 2) == './')
              meta.alias = pkgName + meta.alias.substr(1);
            if (meta.loader && meta.loader.substr(0, 2) == './')
              meta.loader = pkgName + meta.loader.substr(1);
            
            extend(load.metadata, meta);
          }
        }

        return address;
      });
    };
  });

})();/*
  SystemJS Loader Plugin Support

  Supports plugin loader syntax with "!", or via metadata.loader

  The plugin name is loaded as a module itself, and can override standard loader hooks
  for the plugin resource. See the plugin section of the systemjs readme.
*/
(function() {
  hook('normalize', function(normalize) {
    // plugin syntax normalization
    return function(name, parentName) {
      var loader = this;
      // if parent is a plugin, normalize against the parent plugin argument only
      var parentPluginIndex;
      if (parentName && (parentPluginIndex = parentName.indexOf('!')) != -1)
        parentName = parentName.substr(0, parentPluginIndex);

      name = normalize.call(loader, name, parentName);

      // if this is a plugin, normalize the plugin name and the argument
      var pluginIndex = name.lastIndexOf('!');
      if (pluginIndex != -1) {
        var argumentName = name.substr(0, pluginIndex);
        var pluginName = name.substr(pluginIndex + 1) || argumentName.substr(argumentName.lastIndexOf('.') + 1);
        
        argumentName = loader.normalizeSync(argumentName, parentName);

        // note if normalize will add a default js extension
        // if so, remove for backwards compat
        // this is strange and sucks, but will be deprecated
        if (loader.defaultJSExtensions)
          argumentName = argumentName.substr(0, argumentName.length - 3);

        return loader.normalizeSync(argumentName, parentName) + '!' + loader.normalizeSync(pluginName, parentName);
      }

      // standard normalization
      return name;
    };
  });

  SystemJSLoader.prototype.normalizeSync = SystemJSLoader.prototype.normalize;

  hook('locate', function(locate) {
    return function(load) {
      var loader = this;

      var name = load.name;

      // plugin syntax
      var pluginSyntaxIndex = name.lastIndexOf('!');
      if (pluginSyntaxIndex != -1) {
        load.metadata.loader = name.substr(pluginSyntaxIndex + 1);
        load.name = name.substr(0, pluginSyntaxIndex);
      }

      return locate.call(loader, load)
      .then(function(address) {
        var plugin = load.metadata.loader;

        if (!plugin)
          return address;

        // only fetch the plugin itself if this name isn't defined
        if (loader.defined && loader.defined[name])
          return address;

        var pluginLoader = loader.pluginLoader || loader;

        // load the plugin module and run standard locate
        return pluginLoader['import'](plugin)
        .then(function(loaderModule) {
          // store the plugin module itself on the metadata
          load.metadata.loaderModule = loaderModule;
          load.metadata.loaderArgument = name;

          load.address = address;
          if (loaderModule.locate)
            return loaderModule.locate.call(loader, load);

          return address;
        });
      });
    };
  });

  hook('fetch', function(fetch) {
    return function(load) {
      var loader = this;
      if (load.metadata.loaderModule && load.metadata.loaderModule.fetch) {
        load.metadata.scriptLoad = false;
        return load.metadata.loaderModule.fetch.call(loader, load, function(load) {
          return fetch.call(loader, load);
        });
      }
      else {
        return fetch.call(loader, load);
      }
    };
  });

  hook('translate', function(translate) {
    return function(load) {
      var loader = this;
      if (load.metadata.loaderModule && load.metadata.loaderModule.translate)
        return Promise.resolve(load.metadata.loaderModule.translate.call(loader, load)).then(function(result) {
          if (typeof result == 'string')
            load.source = result;
          return translate.call(loader, load);
        });
      else
        return translate.call(loader, load);
    };
  });

  hook('instantiate', function(instantiate) {
    return function(load) {
      var loader = this;
      if (load.metadata.loaderModule && load.metadata.loaderModule.instantiate)
        return Promise.resolve(load.metadata.loaderModule.instantiate.call(loader, load)).then(function(result) {
          load.metadata.format = 'defined';
          load.metadata.execute = function() {
            return result;
          };
          return instantiate.call(loader, load);
        });
      else
        return instantiate.call(loader, load);
    };
  });

})();
/*
 * Alias Extension
 *
 * Allows a module to be a plain copy of another module by module name
 *
 * System.meta['mybootstrapalias'] = { alias: 'bootstrap' };
 *
 */
(function() {
  // aliases
  hook('fetch', function(fetch) {
    return function(load) {
      var alias = load.metadata.alias;
      if (alias) {
        load.metadata.format = 'defined';
        this.defined[load.name] = {
          declarative: true,
          deps: [alias],
          declare: function(_export) {
            return {
              setters: [function(module) {
                for (var p in module)
                  _export(p, module[p]);
              }],
              execute: function() {}
            };
          }
        };
        return '';
      }

      return fetch.call(this, load);
    };
  });
})();/*
 * Meta Extension
 *
 * Sets default metadata on a load record (load.metadata) from
 * loader.metadata via System.meta function.
 *
 *
 * Also provides an inline meta syntax for module meta in source.
 *
 * Eg:
 *
 * loader.meta({
 *   'my/module': { deps: ['jquery'] }
 *   'my/*': { format: 'amd' }
 * });
 * 
 * Which in turn populates loader.metadata.
 *
 * load.metadata.deps and load.metadata.format will then be set
 * for 'my/module'
 *
 * The same meta could be set with a my/module.js file containing:
 * 
 * my/module.js
 *   "format amd"; 
 *   "deps[] jquery";
 *   "globals.some value"
 *   console.log('this is my/module');
 *
 * Configuration meta always takes preference to inline meta.
 *
 * Multiple matches in wildcards are supported and ammend the meta.
 *
 *
 * The benefits of the function form is that paths are URL-normalized
 * supporting say
 *
 * loader.meta({ './app': { format: 'cjs' } });
 *
 * Instead of needing to set against the absolute URL (https://site.com/app.js)
 * 
 */

(function() {

  hookConstructor(function(constructor) {
    return function() {
      this.meta = {};
      constructor.call(this);
    };
  });

  hook('locate', function(locate) {
    return function(load) {
      var meta = this.meta;
      var name = load.name;

      // NB for perf, maybe introduce a fast-path wildcard lookup cache here
      // which is checked first

      // apply wildcard metas
      var bestDepth = 0;
      var wildcardIndex;
      for (var module in meta) {
        wildcardIndex = indexOf.call(module, '*');
        if (wildcardIndex === -1)
          continue;
        if (module.substr(0, wildcardIndex) === name.substr(0, wildcardIndex)
            && module.substr(wildcardIndex + 1) === name.substr(name.length - module.length + wildcardIndex + 1)) {
          var depth = module.split('/').length;
          if (depth > bestDepth)
            bestDetph = depth;
          extend(load.metadata, meta[module], bestDepth != depth);
        }
      }

      // apply exact meta
      if (meta[name])
        extend(load.metadata, meta[name]);

      return locate.call(this, load);
    };
  });

  // detect any meta header syntax
  // only set if not already set
  var metaRegEx = /^(\s*\/\*.*\*\/|\s*\/\/[^\n]*|\s*"[^"]+"\s*;?|\s*'[^']+'\s*;?)+/;
  var metaPartRegEx = /\/\*.*\*\/|\/\/[^\n]*|"[^"]+"\s*;?|'[^']+'\s*;?/g;

  function setMetaProperty(target, p, value) {
    var pParts = p.split('.');
    var curPart;
    while (pParts.length > 1) {
      curPart = pParts.shift();
      target = target[curPart] = target[curPart] || {};
    }
    curPart = pParts.shift();
    if (!(curPart in target))
      target[curPart] = value;
  }

  hook('translate', function(translate) {
    return function(load) {
      // NB meta will be post-translate pending transpiler conversion to plugins
      var meta = load.source.match(metaRegEx);
      if (meta) {
        var metaParts = meta[0].match(metaPartRegEx);

        for (var i = 0; i < metaParts.length; i++) {
          var curPart = metaParts[i];
          var len = curPart.length;

          var firstChar = curPart.substr(0, 1);
          if (curPart.substr(len - 1, 1) == ';')
            len--;
        
          if (firstChar != '"' && firstChar != "'")
            continue;

          var metaString = curPart.substr(1, curPart.length - 3);
          var metaName = metaString.substr(0, metaString.indexOf(' '));

          if (metaName) {
            var metaValue = metaString.substr(metaName.length + 1, metaString.length - metaName.length - 1);

            if (metaName.substr(metaName.length - 2, 2) == '[]') {
              metaName = metaName.substr(0, metaName.length - 2);
              load.metadata[metaName] = load.metadata[metaName] || [];
            }

            // temporary backwards compat for previous "deps" syntax
            if (load.metadata[metaName] instanceof Array)
              load.metadata[metaName].push(metaValue);
            else
              setMetaProperty(load.metadata, metaName, metaValue);
          }
        }
      }
      
      return translate.call(this, load);
    };
  });
})();/*
  System bundles

  Allows a bundle module to be specified which will be dynamically 
  loaded before trying to load a given module.

  For example:
  System.bundles['mybundle'] = ['jquery', 'bootstrap/js/bootstrap']

  Will result in a load to "mybundle" whenever a load to "jquery"
  or "bootstrap/js/bootstrap" is made.

  In this way, the bundle becomes the request that provides the module
*/

(function() {
  // bundles support (just like RequireJS)
  // bundle name is module name of bundle itself
  // bundle is array of modules defined by the bundle
  // when a module in the bundle is requested, the bundle is loaded instead
  // of the form System.bundles['mybundle'] = ['jquery', 'bootstrap/js/bootstrap']
  hookConstructor(function(constructor) {
    return function() {
      constructor.call(this);
      this.bundles = {};
      this.loadedBundles_ = {};
    };
  });

  function loadFromBundle(loader, bundle) {
    return Promise.resolve(loader.normalize(bundle))
    .then(function(normalized) {
      loader.loadedBundles_[normalized] = true;
      loader.bundles[normalized] = loader.bundles[normalized] || loader.bundles[bundle];
      return loader.load(normalized);
    })
    .then(function() {
      return '';
    });
  }

  // assign bundle metadata for bundle loads
  hook('locate', function(locate) {
    return function(load) {
      if (load.name in this.loadedBundles_ || load.name in this.bundles)
        load.metadata.bundle = true;

      return locate.call(this, load);
    };
  });

  hook('fetch', function(fetch) {
    return function(load) {
      var loader = this;
      if (loader.trace)
        return fetch.call(loader, load);
      
      // if already defined, no need to load a bundle
      if (load.name in loader.defined)
        return '';

      // check if it is in an already-loaded bundle
      for (var b in loader.loadedBundles_) {
        if (indexOf.call(loader.bundles[b], load.name) != -1)
          return loadFromBundle(loader, b);
      }

      // check if it is a new bundle
      for (var b in loader.bundles) {
        if (indexOf.call(loader.bundles[b], load.name) != -1)
          return loadFromBundle(loader, b);
      }

      return fetch.call(loader, load);
    };
  });
})();
/*
 * Dependency Tree Cache
 * 
 * Allows a build to pre-populate a dependency trace tree on the loader of 
 * the expected dependency tree, to be loaded upfront when requesting the
 * module, avoinding the n round trips latency of module loading, where 
 * n is the dependency tree depth.
 *
 * eg:
 * System.depCache = {
 *  'app': ['normalized', 'deps'],
 *  'normalized': ['another'],
 *  'deps': ['tree']
 * };
 * 
 * System.import('app') 
 * // simultaneously starts loading all of:
 * // 'normalized', 'deps', 'another', 'tree'
 * // before "app" source is even loaded
 */

(function() {
  hookConstructor(function(constructor) {
    return function() {
      constructor.call(this);
      this.depCache = {};
    }
  });

  hook('locate', function(locate) {
    return function(load) {
      var loader = this;
      // load direct deps, in turn will pick up their trace trees
      var deps = loader.depCache[load.name];
      if (deps)
        for (var i = 0; i < deps.length; i++)
          loader['import'](deps[i]);

      return locate.call(loader, load);
    };
  });
})();
  
/*
 * Conditions Extension
 *
 *   Allows a condition module to alter the resolution of an import via syntax:
 *
 *     import $ from 'jquery/#{browser}';
 *
 *   Will first load the module 'browser' via `System.import('browser')` and 
 *   take the default export of that module.
 *   If the default export is not a string, an error is thrown.
 * 
 *   We then substitute the string into the require to get the conditional resolution
 *   enabling environment-specific variations like:
 * 
 *     import $ from 'jquery/ie'
 *     import $ from 'jquery/firefox'
 *     import $ from 'jquery/chrome'
 *     import $ from 'jquery/safari'
 *
 *   It can be useful for a condition module to define multiple conditions.
 *   This can be done via the `.` modifier to specify a member expression:
 *
 *     import 'jquery/#{browser.grade}'
 *
 *   Where the `grade` export of the `browser` module is taken for substitution.
 *
 *   Note that `/` and a leading `.` are not permitted within conditional modules
 *   so that this syntax can be well-defined.
 *
 *
 * Boolean Conditionals
 *
 *   For polyfill modules, that are used as imports but have no module value,
 *   a binary conditional allows a module not to be loaded at all if not needed:
 *
 *     import 'es5-shim#?conditions.needs-es5shim'
 *
 */
(function() {

  var conditionalRegEx = /#\{[^\}]+\}|#\?.+$/;

  hook('normalize', function(normalize) {
    return function(name, parentName, parentAddress) {
      var loader = this;
      var conditionalMatch = name.match(conditionalRegEx);
      if (conditionalMatch) {
        var substitution = conditionalMatch[0][1] != '?';
        
        var conditionModule = substitution ? conditionalMatch[0].substr(2, conditionalMatch[0].length - 3) : conditionalMatch[0].substr(2);

        if (conditionModule[0] == '.' || conditionModule.indexOf('/') != -1)
          throw new TypeError('Invalid condition ' + conditionalMatch[0] + '\n\tCondition modules cannot contain . or / in the name.');

        var conditionExport = 'default';
        var conditionExportIndex = conditionModule.indexOf('.');
        if (conditionExportIndex != -1) {
          conditionExport = conditionModule.substr(conditionExportIndex + 1);
          conditionModule = conditionModule.substr(0, conditionExportIndex);
        }

        var booleanNegation = !substitution && conditionModule[0] == '~';
        if (booleanNegation)
          conditionModule = conditionModule.substr(1);
        
        return loader['import'](conditionModule, parentName, parentAddress)
        .then(function(m) {
          var conditionValue = readMemberExpression(conditionExport, m);

          if (substitution) {
            if (typeof conditionValue !== 'string')
              throw new TypeError('The condition value for ' + conditionalMatch[0] + ' doesn\'t resolving to a string.');
            name = name.replace(conditionalRegEx, conditionValue);
          }
          else {
            if (typeof conditionValue !== 'boolean')
              throw new TypeError('The condition value for ' + conditionalMatch[0] + ' isn\'t resolving to a boolean.');
            if (booleanNegation)
              conditionValue = !conditionValue;
            if (!conditionValue)
              name = '@empty';
          }
          return normalize.call(loader, name, parentName, parentAddress);
        });
      }

      return Promise.resolve(normalize.call(loader, name, parentName, parentAddress));
    };
  });

})();System = new SystemJSLoader();
System.constructor = SystemJSLoader;  // -- exporting --

  if (typeof exports === 'object')
    module.exports = Loader;

  __global.Reflect = __global.Reflect || {};
  __global.Reflect.Loader = __global.Reflect.Loader || Loader;
  __global.Reflect.global = __global.Reflect.global || __global;
  __global.LoaderPolyfill = Loader;

  if (!System) {
    System = new SystemLoader();
    System.constructor = SystemLoader;
  }

  if (typeof exports === 'object')
    module.exports = System;

  __global.System = System;

})(typeof self != 'undefined' ? self : global);}

// auto-load Promise and URL polyfills if needed in the browser
if (typeof Promise === 'undefined' || typeof URL !== 'function') {
  // document.write
  if (typeof document !== 'undefined') {
    var scripts = document.getElementsByTagName('script');
    $__curScript = scripts[scripts.length - 1];
    var curPath = $__curScript.src;
    var basePath = curPath.substr(0, curPath.lastIndexOf('/') + 1);
    window.systemJSBootstrap = bootstrap;
    document.write(
      '<' + 'script type="text/javascript" src="' + basePath + 'system-polyfills.js">' + '<' + '/script>'
    );
  }
  // importScripts
  else if (typeof importScripts !== 'undefined') {
    var basePath = '';
    try {
      throw new Error('_');
    } catch (e) {
      e.stack.replace(/(?:at|@).*(http.+):[\d]+:[\d]+/, function(m, url) {
        basePath = url.replace(/\/[^\/]*$/, '/');
      });
    }
    importScripts(basePath + 'system-polyfills.js');
    bootstrap();
  }
  else {
    bootstrap();
  }
}
else {
  bootstrap();
}


})();