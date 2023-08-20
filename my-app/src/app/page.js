"use client";
import Web3Modal from "web3modal";
import { providers, Contract } from "ethers";
import { useEffect, useRef, useState } from "react";
import{contractAddress,abi} from "./constants";
export default function Home() {

  const [walletConnected, setWalletConnected] = useState(false);
  const web3ModalRef = useRef();


  const getProviderOrSigner=async(needSigner = false)=>
  {

    const provider = await web3ModalRef.current.connect();
    const web3Provider = new providers.Web3Provider(provider);

   
    

    if (needSigner) {
      const signer = web3Provider.getSigner();
      return signer;
    }
    return web3Provider;


  }

  const connectWallet=async()=>
  {
    try{
      await getProviderOrSigner();
      setWalletConnected(true);


    }
    catch(err)
    {
      console.log(err.message)
    }
  }

  useEffect(()=>
  {
    if (!walletConnected) {
      
      web3ModalRef.current = new Web3Modal({
        network: "goerli",
        providerOptions: {},
        disableInjectedProvider: false,
      });
      connectWallet();
    }
    

  },[walletConnected])


  const renderButton=()=>
  {
    if(walletConnected){
      return(
        <div>Wallet connected</div>
      )

    }
    else{
      return(
       <div>
        <button onClick={connectWallet}>Connect your wallet</button>
       </div>
      )
    }

  }
  return (
    <div>
      <div>MarketPlace</div>
      {renderButton()}

    </div>
    
  )
}
