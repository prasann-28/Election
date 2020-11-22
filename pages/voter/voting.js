import Head from 'next/head'
import React, { Component } from 'react'
import Web3 from 'web3'
import Election from '../../build/contracts/Election.json'
import { Button, Form, Segment, Input } from 'semantic-ui-react'
import 'semantic-ui-css/semantic.min.css'
import 'next/router'
import { Card, Icon, Image } from 'semantic-ui-react'


export default class Login extends Component {
    async componentDidMount() {
      await this.loadWeb3()
        await this.loadBlockchainData()
      }
      
      async loadBlockchainData() {
        const web3 = window.web3;
    
        const accounts = await web3.eth.getAccounts();
        this.setState({ account: accounts[0] });
        const networkId = await web3.eth.net.getId();
        
        
        //Loads Lottery contract
        const electionData = Election.networks[networkId];
        if(electionData){
          
          const election = new web3.eth.Contract(Election.abi, electionData.address);
          this.setState({election: election});
          
          let manager = await election.methods.manager().call();
          this.setState({manager: manager})

          let voterid = await election.methods.voters(accounts[0]).call();
          this.setState({voter: voterid})

          if(!voterid.authenticated){
            window.alert("Login first")
            window.location.href= "../login"
          }else{
            this.setState({head: "Vote Here"})
          }
      } else {
        window.alert('Not deployed to network');
      }
      this.setState({loading: false});
    
    }
    
      
      async loadWeb3() {
        if (window.ethereum) {
          window.web3 = new Web3(window.ethereum)
          await window.ethereum.enable()
        }
        else if (window.web3) {
          window.web3 = new Web3(window.web3.currentProvider)
        }
        else {
          window.alert('Non-Ethereum browser detected. You should consider trying MetaMask!')
        }
      }
    
      constructor(props) {
        super(props)
        this.state = {
          election: {},
          manager: '', 
          loading: true,
          account: '0x0',
          message: '',
          head: ''
        }
      }
 

      render() {
        return (
          <>
          <Head><title>{this.state.head}</title></Head>
        <div>
        <Segment basic inverted padded='very' raised size='massive'>
            <h1><b>Vote Here</b></h1></Segment>
        <div style = {{paddingLeft: '45px'}}>
        <div className="ui card"><div className="image"><img src="https://react.semantic-ui.com/images/avatar/large/matthew.png"/></div><div className="content"><div className="header">Matthew</div><div className="description">Matthew is a musician living in Nashville.</div></div><div className="extra content"><Button className = "ui-button">Cast Vote</Button></div></div>
        </div>
        <h2>{this.state.message}</h2>
        <h1>{this.state.account}</h1>
        </div>
          </>
        );
      } 

    }