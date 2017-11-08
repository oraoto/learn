const vm = require('vm');
const fs = require('fs');

function codeGen(mod, params) {
    let p = JSON.stringify(params);
    let code = `
        (function() {
            delete require.cache[require.resolve('${mod}')]
            const m = require('${mod}');
            let param = JSON.parse('${p}');
            m(...param);
        })()
        `;
    return code;
}

function runInVM() {
    let code = codeGen('./add', [1, 2]);
    let script = new vm.Script(code);
    let sandbox = {require: require}
    script.runInNewContext(sandbox);
}

function run(mod, ...args) {
    // delete require.cache[require.resolve(mod)];
    let modules = currentModules();
    const m = require(mod);
    m(...args);
    invalidModules({except: modules});
}

// setTimeout(() => runInVM(), 1000);
// setTimeout(() => runInVM(), 10000);

run('./add', 1, 2);
console.log('Now modify add.js');
setTimeout(() => run('./add', 2, 3), 10000);

function invalidModules(options) {
    let except = options.except;
    for (let m in require.cache) {
        if (except.find((n) => n == m)) {
            continue;
        }
        console.log('invalidate ' + m);
        delete require.cache[m];
    }
}

function currentModules() {
    let modules = [];
    for (let m in require.cache) {
        modules.push(m);
    }
    return modules;
}