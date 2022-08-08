import logo from './logo.svg';
import './App.css';
import Caver from 'caver-js';

// 1. 컨트랙트 배포 -> 주소 가져오기
// 2. caver.js로 컨트랙트 연동
// 3. 가져온 컨트랙트 실행 결과를 웹에 표현하기

const COUNT_CONTRACT_ADDRESS='0x2bAe5b449433301B9678fea81fA421EfC8b31c1b';
const ACCESS_KEY_ID = 'KASK8WXCV29NGFTS9S78Z15I';
const SECRET_ACCESS_KEY = 'cPqKDyw_dfpkPnDO91s813zQ-7-Rod1oTUzD7KD7';
const CHAIN_ID ='1001'; // mainnet: 8217 / testnet:1001
const COUNT_ABI = '[ { "inputs": [], "name": "count", "outputs": [ { "internalType": "uint256", "name": "", "type": "uint256" } ], "stateMutability": "view", "type": "function" }, { "inputs": [], "name": "getBlockNumber", "outputs": [ { "internalType": "uint256", "name": "", "type": "uint256" } ], "stateMutability": "view", "type": "function" }, { "inputs": [ { "internalType": "uint256", "name": "_count", "type": "uint256" } ], "name": "setCount", "outputs": [], "stateMutability": "nonpayable", "type": "function" } ]'


const option ={
  headers:[
    {
      name: "Authorization",
      value: "Basic " + Buffer.from(ACCESS_KEY_ID + ":" + SECRET_ACCESS_KEY).toString("base64")
    },
    {name: "x-chain-id", value: CHAIN_ID}
  ]
}

const caver = new Caver(new Caver.providers.HttpProvider("https://node-api.klaytnapi.com/v1/klaytn", option));
const CountContract = new caver.contract(JSON.parse(COUNT_ABI), COUNT_CONTRACT_ADDRESS)
const readCount = async() => {
  const _count = await CountContract.methods.count().call();
  console.log(_count);
}


const getBalance = (address) => {
  return caver.rpc.klay.getBalance(address).then((response) => {
    //클레이 잔고를 알려주세요   -> 응답이 오면

    // 응답이 16진수로 오는데, 클레이단위 숫자로 컨버트
    const balance = caver.utils.convertFromPeb(caver.utils.hexToNumberString(response));
    console.log(balance);
    return balance;

  })

}


function App() {
  readCount();
  getBalance('0xd3766F9652419Dd67b86E73D590fdd7CfDb41a74');
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          hi 
        </p>
      </header>
    </div>
  );
}

export default App;
