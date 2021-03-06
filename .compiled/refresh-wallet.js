// Generated by LiveScript 1.6.0
(function(){
  var calcWallet, loadAllTransactions, loadRates, whois, ref$, run, task, refreshWallet;
  calcWallet = require('./calc-wallet.ls');
  loadAllTransactions = require('./transactions.ls').loadAllTransactions;
  loadRates = require('./load-rates.ls');
  whois = require('./whois.ls');
  ref$ = require('./workflow.ls'), run = ref$.run, task = ref$.task;
  refreshWallet = function(web3, store, cb){
    store.current.refreshing = true;
    return whois(web3, store, function(err, name){
      var task1, task2, task3;
      if (err == null && (name != null ? name : "").length > 0) {
        store.current.nicknamefull = name;
      }
      task1 = task(function(cb){
        return loadRates(store, cb);
      });
      task2 = task(function(cb){
        return loadAllTransactions(store, cb);
      });
      task3 = task(function(cb){
        return calcWallet(store, cb);
      });
      return run([
        {
          task1: task1,
          task2: task2
        }, task3
      ]).then(function(){
        store.current.refreshing = false;
        return cb(null);
      });
    });
  };
  module.exports = refreshWallet;
}).call(this);
