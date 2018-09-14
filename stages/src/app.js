var web3Provider = null;

var StagesTokenContract;

var stagesStatic = 0;

var contractAddress = '0x9d5d8f45d9224234b3e5863169dbfb9a1bdc35b1';

var contractInstance;

function init() {
    initWeb3();

    initTime();
}

function initWeb3() {

    if (typeof web3 !== 'undefined' && typeof web3.currentProvider !== 'undefined') {
        web3Provider = web3.currentProvider;
        web3 = new Web3(web3Provider);
    } else {
        console.error('No web3 provider found. Please install Metamask on your browser.');
        alert('No web3 provider found. Please install Metamask on your browser.');
    }


    // web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:7545"));
    // web3.eth.defaultAccount = web3.eth.accounts[1];

    //console.log(web3.eth.accounts[0]);
    initWrestlingContract();
}

function initTime() {
    // 3天为一个周期


    moveTimeToNext3Days();
}


function moveTimeToNext3Days() {
    // 众筹期
    let t1Begin = moment().add(stagesStatic, 'day');

    let t1BeginDate = t1Begin.format('YYYY-MM-DD');
    let t1BeginTime = t1Begin.format('HH:mm');

    document.getElementById('saleBeginTimeDate').value = t1BeginDate;
    document.getElementById('saleBeginTimeTime').value = t1BeginTime;

    let t1End = t1Begin.add(1, 'day');

    let t1EndDate = t1End.format('YYYY-MM-DD');
    let t1EndTime = t1End.format('HH:mm');

    document.getElementById('saleEndTimeDate').value = t1EndDate;
    document.getElementById('saleEndTimeTime').value = t1EndTime;

    // 冻结期
    let t2Begin = t1End;

    let t2BeginDate = t2Begin.format('YYYY-MM-DD');
    let t2BeginTIme = t2Begin.format('HH:mm');

    document.getElementById('lockBeginTimeDate').value = t2BeginDate;
    document.getElementById('lockBeginTimeTime').value = t2BeginTIme;

    let t2End = t2Begin.add(1, 'day');

    let t2EndDate = t2End.format('YYYY-MM-DD');
    let t2EndTime = t2End.format('HH:mm');

    document.getElementById('lockEndTimeDate').value = t2EndDate;
    document.getElementById('lockEndTimeTime').value = t2EndTime;

    // 投票期

    let t3Beign = t2End;

    let t3BeginDate = t3Beign.format('YYYY-MM-DD');
    let t3BeginTIme = t3Beign.format('HH:mm');

    document.getElementById('voteBeginTimeDate').value = t3BeginDate;
    document.getElementById('voteBeginTimeTime').value = t3BeginTIme;

    let t3End = t3Beign.add(1, 'day');

    let t3EndDate = t3End.format('YYYY-MM-DD');
    let t3EndTime = t3End.format('HH:mm');

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

        contractInstance = StagesTokenContract.at(contractAddress);
    });
}

String.prototype.format = function () {
    var formatted = this;
    for (var arg in arguments) {
        formatted = formatted.replace("{" + arg + "}", arguments[arg]);
    }
    return formatted;
};

function queryStages() {

    contractInstance.CurrentStageIdx().then(function (result) {
        // 获取当前期数index
        let currentStageIdx = result.toNumber();

        contractInstance.StagesLen().then(function (result) {
            // 所有期数
            stagesLen = document.getElementById("StagesLen").innerHTML = result.toNumber();

            console.log("所有期数: " + stagesLen + "当前期数: " + currentStageIdx);

            let stagesInfoDiv = document.getElementById("stagesInfo");
            while (stagesInfoDiv.hasChildNodes()) {
                stagesInfoDiv.removeChild(stagesInfoDiv.firstChild);
            }

            for (let i = stagesLen - 1; i >= 0; i--) {
                contractInstance.GetStages(i).then(function (result) {

                    let newH5 = document.createElement("h5");
                    if (i === currentStageIdx) {
                        newH5.setAttribute("style", "color:red;");
                    }

                    newH5.textContent = "第{0}期:".format(i);
                    stagesInfoDiv.appendChild(newH5);

                    console.log(result);

                    let curStageInfo = "";
                    let eles = result.split("|");

                    let t1Begin = moment.unix(parseInt(eles[0])).format('YYYY-MM-DD HH:mm:ss');
                    let t1End = moment.unix(parseInt(eles[1])).format('YYYY-MM-DD HH:mm:ss');
                    let t2Begin = moment.unix(parseInt(eles[2])).format('YYYY-MM-DD HH:mm:ss');
                    let t2End = moment.unix(parseInt(eles[3])).format('YYYY-MM-DD HH:mm:ss');
                    let t3Begin = moment.unix(parseInt(eles[4])).format('YYYY-MM-DD HH:mm:ss');
                    let t3End = moment.unix(parseInt(eles[5])).format('YYYY-MM-DD HH:mm:ss');
                    let changeRate = eles[6];
                    let targetAgreeRate = eles[7];
                    let investorNum = eles[8];

                    let newP = document.createElement("p");
                    newP.textContent = "1.众筹期:{0}~{1}".format(t1Begin, t1End);
                    stagesInfoDiv.appendChild(newP);

                    newP = document.createElement("p");
                    newP.textContent = "2.冻结期:{0}~{1}".format(t2Begin, t2End);
                    stagesInfoDiv.appendChild(newP);

                    newP = document.createElement("p");
                    newP.textContent = "3.投票期:{0}~{1}".format(t3Begin, t3End);
                    stagesInfoDiv.appendChild(newP);

                    newP = document.createElement("p");
                    newP.textContent = "兑换比例:{0} 投票通过比例:{1} 投资者数量:{2}".format(changeRate, targetAgreeRate, investorNum);
                    stagesInfoDiv.appendChild(newP);

                    for (let k = 0; k < investorNum; k++) {
                        contractInstance.GetStageInvestor(i, k).then(function (result) {
                            let eles = result[1].split("|");

                            let state_ = "";
                            if (eles[2] === '1') {
                                state_ = "没有投票"
                            } else if (eles[2] === '2') {
                                state_ = "同意"
                            } else if (eles[2] === '3') {
                                state_ = "反对"
                            }

                            newP = document.createElement("p");
                            newP.textContent = "投资者地址:{0} : 投资剩余ABS数量{1} 应得剩余token数量:{2} 状态:{3}".format(
                                result[0], eles[0], eles[1], state_
                            );
                            stagesInfoDiv.appendChild(newP);

                        }).catch(e => {
                            alert(e);
                        });
                    }

                }).catch(e => {
                    alert(e);
                });

            }

        }).catch(e => {
            alert(e);
        });

    }).catch(e => {
        alert(e);
    });
}

function flushBasicData() {
    // TODO 怎么重构

    // string
    contractInstance.name().then(function (result) {
        document.getElementById("name").innerHTML = result;
    }).catch(e => {
        alert(e);
    });

    contractInstance.symbol().then(function (result) {
        document.getElementById("symbol").innerHTML = result;
    }).catch(e => {
        alert(e);
    });

    contractInstance.decimals().then(function (result) {
        document.getElementById("decimals").innerHTML = result;
    }).catch(e => {
        alert(e);
    });

    // address
    contractInstance.Item().then(function (result) {
        document.getElementById("Item").innerHTML = result.toString();
    }).catch(e => {
        alert(e);
    });

    // uint256
    contractInstance.ItemBalance().then(function (result) {
        let num = new Number(result.toString());
        num = num.toLocaleString();
        document.getElementById("ItemBalance").innerHTML = num;
    }).catch(e => {
        alert(e);
    });

    contractInstance.StagesLen().then(function (result) {
        document.getElementById("StagesLen").innerHTML = result.toString();
    }).catch(e => {
        alert(e);
    });

    contractInstance.CurrentStageIdx().then(function (result) {
        document.getElementById("CurrentStageIdx").innerHTML = result.toString();
    }).catch(e => {
        alert(e);
    });

}

function appendStage() {
    let date = document.getElementById("saleBeginTimeDate").value;
    let time = document.getElementById("saleBeginTimeTime").value;
    let saleBeginTime = new Date(date + " " + time).getTime() / 1000;

    date = document.getElementById("saleEndTimeDate").value;
    time = document.getElementById("saleEndTimeTime").value;
    let saleEndTime = new Date(date + " " + time).getTime() / 1000;

    date = document.getElementById("lockBeginTimeDate").value;
    time = document.getElementById("lockBeginTimeTime").value;
    let lockBeginTime = new Date(date + " " + time).getTime() / 1000;

    date = document.getElementById("lockEndTimeDate").value;
    time = document.getElementById("lockEndTimeTime").value;
    let lockEndTime = new Date(date + " " + time).getTime() / 1000;

    date = document.getElementById("voteBeginTimeDate").value;
    time = document.getElementById("voteBeginTimeTime").value;
    let voteBeginTime = new Date(date + " " + time).getTime() / 1000;

    date = document.getElementById("voteEndTimeDate").value;
    time = document.getElementById("voteEndTimeTime").value;
    let voteEndTime = new Date(date + " " + time).getTime() / 1000;

    let changeRate = document.getElementById("changeRate").value;

    let targetAgreeRate = document.getElementById("targetAgreeRate").value;

    let saleBeginTimeBig = web3.toBigNumber(saleBeginTime);
    let saleEndTimeBig = web3.toBigNumber(saleEndTime);
    let lockBeginTimeBig = web3.toBigNumber(lockBeginTime);
    let lockEndTimeBig = web3.toBigNumber(lockEndTime);
    let voteBeginTimeBig = web3.toBigNumber(voteBeginTime);
    let voteEndTimeBig = web3.toBigNumber(voteEndTime);
    let changeRateBig = web3.toBigNumber(changeRate);
    let targetAgreeRateBig = web3.toBigNumber(targetAgreeRate);

    contractInstance.AppendStage(
        saleBeginTimeBig,
        saleEndTimeBig,
        lockBeginTimeBig,
        lockEndTimeBig,
        voteBeginTimeBig,
        voteEndTimeBig,
        changeRateBig,
        targetAgreeRateBig, {gas: 3141592, from: web3.eth.defaultAccount}).then(function (result) {
        alert("添加成功");
    }).catch(e => {
        alert(e);
    });


    flushBasicData();


}

function Invest() {
    let ABSNum = document.getElementById("InvestorABSNum").value;

    if (ABSNum === "") {
        alert("投资ABS数量为空");
        return;
    }

    let ABSNumBig = web3.toBigNumber(ABSNum);


    contractInstance.Invest({
        from: web3.eth.defaultAccount,
        gas: 3141592,
        value: web3.toWei(ABSNumBig, "ether")
    }).then(function (result) {
        alert("投资成功");
    }).catch(e => {
        alert(e);
    });
}


function Vote() {
    voteValue = document.getElementById("VoteValue").value;

    let voteValueBig = web3.toBigNumber(voteValue);

    contractInstance.Vote(voteValueBig, {
        from: web3.eth.defaultAccount,
        gas: 3141592
    }).then(function (result) {
        alert("投票成功");
    }).catch(e => {
        alert(e);
    });
}

function switchStage() {
    contractInstance.SwitchStage({gas: 3141592, from: web3.eth.defaultAccount}).then(function (result) {
        alert("切换成功");
    }).catch(e => {
        alert(e);
    });
}

function InvestorWithdrawToken() {
    contractInstance.InvestorWithdrawToken({gas: 3141592, from: web3.eth.defaultAccount}).then(function (reslt) {
        alert("提取成功");
    }).catch(e => {
        alert(e);
    });

}

function InvestorWithdrawAbs() {
    contractInstance.InvestorWithdrawAbs({gas: 3141592, from: web3.eth.defaultAccount}).then(function (reslt) {
        alert("提取成功");
    }).catch(e => {
        alert(e);
    });
}

function ItemWithdrawABS() {
    contractInstance.ItemWithdrawABS({gas: 3141592, from: web3.eth.defaultAccount}).then(function (reslt) {
        alert("提取成功");
    }).catch(e => {
        alert(e);
    });
}

function ItemWithdrawToken() {
    contractInstance.ItemWithdrawToken({gas: 3141592, from: web3.eth.defaultAccount}).then(function (reslt) {
        alert("提取成功");
    }).catch(e => {
        alert(e);
    });
}

$(function () {
    $(window).load(function () {
        init();
    });
});
