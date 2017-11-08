require('./mul');

module.exports = function(a, b) {
    let sum = a + b;
    console.log(`${a} ++ ${b} = ${sum}`)
    return sum;
}