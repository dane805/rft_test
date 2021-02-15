pragma solidity ^0.7.3; // solidity 처음은 항상 pragma(컴파일러)로 시작한다

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol'; // for fungible token to manipulate DAI token
import '@openzeppelin/contracts/token/ERC20/ERC20.sol'; // for fungible token to manipulate DAI token

// define our smart contract
contract RFT is ERC20 { // inherit from ERC20
  uint public icoSharePrice;  // total supply for all of this share
  uint public icoShareSupply; // price for each share
  uint public icoEnd; // limited in time

  uint public nftId; // specify its id in the smart contract of the nft
  IERC721 public nft; // pointer to NFT token
  IERC20 public dai;

  address public admin; // person that buy the nft token and send it to the fungible nft

  constructor( // a function which is called when we deploy the smart contract we're gonna pass a couple of argumetns
    string memory _name, 
    string memory _symbol,
    address _nftAddress, 
    uint _nftId,
    uint _icoSharePrice,
    uint _icoShareSupply,
    address _daiAddress
  )
  ERC20(_name, _symbol)
  {
    nftId = _nftId;
    nft = IERC721(_nftAddress);
    icoSharePrice = _icoSharePrice;
    icoShareSupply = _icoShareSupply;
    dai = IERC20(_daiAddress);
    admin = msg.sender;
  }

  // function to start the ICO
  function startIco() external {
    require(msg.sender == admin, 'only admin');
    nft.transferFrom(msg.sender, address(this), nftId); // center of transaction
    icoEnd = block.timestamp + 7 * 86400;
  }

  // buy a share of this contract
  function buyShare(uint shareAmount) external {
    require(icoEnd > 0, 'ICO not started yet');
    require(block.timestamp <= icoEnd, 'ICO is finished');
    require(totalSupply() + shareAmount <= icoShareSupply, 'not enough shares left');
    uint daiAmount = shareAmount * icoSharePrice;
    dai.transferFrom(msg.sender, address(this), daiAmount);
    _mint(msg.sender, shareAmount);
  }

  function withdrawIcoProfits() external {
    require(msg.sender == admin, 'only admin');
    require(block.timestamp > icoEnd, 'ICO not finished yet');
    uint daiBalance = dai.balanceOf(address(this));
    if (daiBalance > 0) {
      dai.transfer(admin, daiBalance);
    }
    uint unsoldShareBalance = icoShareSupply - totalSupply();
    if (unsoldShareBalance > 0) {
      _mint(admin, unsoldShareBalance);
    }
  }
}
