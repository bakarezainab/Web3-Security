// SPDX-License-Identifier: MIT
pragma solidity 0.8.13; 

contract DeployW3CXII{

    //  constructor(address payable W3CXII) payable {
    //     selfdestruct(W3CXII);
    //  }

    constructor () payable {}
    

    function send (address payable W3CXII) external{
        selfdestruct(W3CXII);
    }
}