var web3Provider = null;

var StagesTokenContract;


var stagesStatic = 0;

function init() {
    initWeb3();

    initTime();
}


function initWeb3() {
    //if (typeof web3 !== 'undefined' && typeof web3.currentProvider !== 'undefined') {
    //web3Provider = web3.currentProvider;
    //web3 = new Web3(web3Provider);
    web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:7545"));

    //} else {
    //    console.error('No web3 provider found. Please install Metamask on your browser.');
    //     alert('No web3 provider found. Please install Metamask on your browser.');
    //}
    web3.eth.defaultAccount = web3.eth.accounts[1];

    //console.log(web3.eth.accounts[0]);
    initWrestlingContract();
}

function initTime() {
    // 3天为一个周期


    moveTimeToNext3Days();
}


function moveTimeToNext3Days() {
    // 众筹期
    var t1Begin = moment().add(stagesStatic, 'day');

    var t1BeginDate = t1Begin.format('YYYY-MM-DD');
    var t1BeginTime = t1Begin.format('HH:mm');

    document.getElementById('saleBeginTimeDate').value = t1BeginDate;
    document.getElementById('saleBeginTimeTime').value = t1BeginTime;

    var t1End = t1Begin.add(1, 'day');

    var t1EndDate = t1End.format('YYYY-MM-DD');
    var t1EndTime = t1End.format('HH:mm');

    document.getElementById('saleEndTimeDate').value = t1EndDate;
    document.getElementById('saleEndTimeTime').value = t1EndTime;

    // 冻结期
    var t2Begin = t1End;

    var t2BeginDate = t2Begin.format('YYYY-MM-DD');
    var t2BeginTIme = t2Begin.format('HH:mm');

    document.getElementById('lockBeginTimeDate').value = t2BeginDate;
    document.getElementById('lockBeginTimeTime').value = t2BeginTIme;

    var t2End = t2Begin.add(1, 'day');

    var t2EndDate = t2End.format('YYYY-MM-DD');
    var t2EndTime = t2End.format('HH:mm');

    document.getElementById('lockEndTimeDate').value = t2EndDate;
    document.getElementById('lockEndTimeTime').value = t2EndTime;

    // 投票期

    var t3Beign = t2End;

    var t3BeginDate = t3Beign.format('YYYY-MM-DD');
    var t3BeginTIme = t3Beign.format('HH:mm');

    document.getElementById('voteBeginTimeDate').value = t3BeginDate;
    document.getElementById('voteBeginTimeTime').value = t3BeginTIme;

    var t3End = t3Beign.add(1, 'day');

    var t3EndDate = t3End.format('YYYY-MM-DD');
    var t3EndTime = t3End.format('HH:mm');

    document.getElementById('voteEndTimeDate').value = t3EndDate;
    document.getElementById('voteEndTimeTime').value = t3EndTime;

    stagesStatic += 3;
}

function initWrestlingContract() {
    $.getJSON('StagesToken.json', function (data) {
        StagesTokenContract = TruffleContract(data);

        console.log(StagesTokenContract);
        // StagesTokenContract.setProvider(web3Provider);

        StagesTokenContract.setProvider(web3.currentProvider);

    });
}

function flushBasicData() {
    // TODO 怎么重构

    // string
    StagesTokenContract.deployed().then(function (instance) {
        return instance.name();
    }).then(function (result) {
        document.getElementById("name").innerHTML = result;
    });

    StagesTokenContract.deployed().then(function (instance) {
        return instance.symbol();
    }).then(function (result) {
        document.getElementById("symbol").innerHTML = result;
    });

    StagesTokenContract.deployed().then(function (instance) {
        return instance.decimals();
    }).then(function (result) {
        document.getElementById("decimals").innerHTML = result;
    });

    // uint256
    StagesTokenContract.deployed().then(function (instance) {
        return instance.Item();
    }).then(function (result) {
        document.getElementById("Item").innerHTML = result.toString();
    });

    StagesTokenContract.deployed().then(function (instance) {
        return instance.ItemBalance();
    }).then(function (result) {

        var num = new Number(result.toString());
        num = num.toLocaleString();

        document.getElementById("ItemBalance").innerHTML = num;
    });

    StagesTokenContract.deployed().then(function (instance) {
        return instance.StagesLen();
    }).then(function (result) {
        document.getElementById("StagesLen").innerHTML = result.toString();
    });

    StagesTokenContract.deployed().then(function (instance) {
        return instance.CurrentStageIdx();
    }).then(function (result) {
        document.getElementById("CurrentStageIdx").innerHTML = result.toString();
    });
}

function appendStage() {
    var date = document.getElementById("saleBeginTimeDate").value;
    var time = document.getElementById("saleBeginTimeTime").value;
    var saleBeginTime = new Date(date + " " + time).getTime();

    date = document.getElementById("saleEndTimeDate").value;
    time = document.getElementById("saleEndTimeTime").value;
    var saleEndTime = new Date(date + " " + time).getTime();

    date = document.getElementById("lockBeginTimeDate").value;
    time = document.getElementById("lockBeginTimeTime").value;
    var lockBeginTime = new Date(date + " " + time).getTime();

    date = document.getElementById("lockEndTimeDate").value;
    time = document.getElementById("lockEndTimeTime").value;
    var lockEndTime = new Date(date + " " + time).getTime();

    date = document.getElementById("voteBeginTimeDate").value;
    time = document.getElementById("voteBeginTimeTime").value;
    var voteBeginTime = new Date(date + " " + time).getTime();

    date = document.getElementById("voteEndTimeDate").value;
    time = document.getElementById("voteEndTimeTime").value;
    var voteEndTime = new Date(date + " " + time).getTime();

    var changeRate = document.getElementById("changeRate").value;

    var targetAgreeRate = document.getElementById("targetAgreeRate").value;

    StagesTokenContract.deployed().then(function (instance) {

        var saleBeginTimeBig = web3.toBigNumber(saleBeginTime);
        var saleEndTimeBig = web3.toBigNumber(saleEndTime);
        var lockBeginTimeBig = web3.toBigNumber(lockBeginTime);
        var lockEndTimeBig = web3.toBigNumber(lockEndTime);
        var voteBeginTimeBig = web3.toBigNumber(voteBeginTime);
        var voteEndTimeBig = web3.toBigNumber(voteEndTime);
        var changeRateBig = web3.toBigNumber(changeRate);
        var targetAgreeRateBig = web3.toBigNumber(targetAgreeRate);

        instance.AppendStage(
            saleBeginTimeBig,
            saleEndTimeBig,
            lockBeginTimeBig,
            lockEndTimeBig,
            voteBeginTimeBig,
            voteEndTimeBig,
            changeRateBig,
            targetAgreeRateBig, {gas: 3141592});
    });
}

function Invest() {
    var ABSNum = document.getElementById("InvestorABSNum").value;

    StagesTokenContract.deployed().then(function (instance) {

        var ABSNumBig = web3.toBigNumber(ABSNum);

        instance.Invest({
            from: web3.eth.accounts[1],
            gas: 3141592,
            value: web3.toWei(ABSNumBig, "ether")
        });
    });
}


function switchStage() {
    StagesTokenContract.deployed().then(function (instance) {
        instance.SwitchStage({gas: 3141592});
    });
}


$(function () {
    $(window).load(function () {
        init();
    });
});
