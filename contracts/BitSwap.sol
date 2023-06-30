// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract BitSwap is ERC20 {
    using SafeMath for uint256;
    //track earned dexialp tokens per user
    // user > pool pair number > token address 1 > token address 2 > amount of DexitaLP tokens
    mapping (address => mapping(uint256 => mapping(address => mapping(address => uint256)))) private Earned_dexitalptokens_peruser;
    // track amount of tokens added per user in specific pool
    // address user > pool pair number > token address > amount of token of that address
    mapping (address => mapping(uint256 => mapping(address => uint256))) private Tokensaddedperuser;
    // token 1 address > token 2 address > pool number > dexita lp tokens
    mapping (address => mapping(address => mapping (uint256 => uint256))) private totalsupplyperpair;
    // track reserves of each pair 
    // pair number (1 or 2 or 3 and so on) > address of token > reserves
    // I mapped each pair in the liquidity pool to a number
    mapping (uint256 => mapping(address => uint256 )) private reservesperpairs;
    //track the pairs
    uint256 private currentpair;
    // struct for pairs
    struct tokenpairs{
        address token1;
        address token2;
    }
    // array of structs to tract token pair
    tokenpairs [] private Pairs;

    constructor () ERC20 ("Dexita liquidity provider tokens", "DexitaLP"){
    }
    //Function to create token pairs 
    function CreatePairs (address token1 , address token2) public{
        tokenpairs memory newtokenpairs = tokenpairs (token1,token2);
        Pairs.push(newtokenpairs);
    }
   
    //Function to add liquidity 
    function AddLiquidityERC20tokens (address _token1, uint256 _amount1 ,address _token2, uint256 _amount2, uint256 poolpairnumber) public returns (uint256){
        CreatePairs(_token1,_token2);
        (uint256 token1_reserves , uint256 token2_reserves) = GetReservesPerpair(poolpairnumber,_token1, _token2);
        uint256 amount_tobeadded_token1;
        uint256 amount_tobeadded_token2;
        uint256 liquidity_amount;
        //First time to add liquidity
        if (token1_reserves == 0 || token2_reserves == 0){
            amount_tobeadded_token1 = _amount1;
            amount_tobeadded_token2 = _amount2;
            IERC20(_token1).transferFrom(msg.sender, address(this), _amount1);
            IERC20(_token2).transferFrom(msg.sender, address(this), _amount2);
            liquidity_amount = Math.sqrt(_amount1.mul(_amount2));
        }
        // IF not the first time to add liquidity 
        else{
            uint256 totalsupplypereachpair = GetTotalSupplyPerPair(_token1, _token2, poolpairnumber);
            (amount_tobeadded_token1,amount_tobeadded_token2) = GetMinimumAmountOfTokens_addliquidity(token1_reserves, _amount1 , token2_reserves , _amount2);
            IERC20(_token1).transferFrom(msg.sender, address(this), amount_tobeadded_token1);
            IERC20(_token2).transferFrom(msg.sender, address(this), amount_tobeadded_token2);
            liquidity_amount = Math.min(amount_tobeadded_token1.mul(totalsupplypereachpair) / token1_reserves,amount_tobeadded_token2.mul(totalsupplypereachpair) / token2_reserves);
        }
        _mint(msg.sender, liquidity_amount);
        totalsupplyperpair[_token1][_token2][poolpairnumber] += liquidity_amount;
        Earned_dexitalptokens_peruser[msg.sender][poolpairnumber][_token1][_token2] += liquidity_amount;
        reservesperpairs[poolpairnumber][_token1] += amount_tobeadded_token1;
        reservesperpairs[poolpairnumber][_token2] += amount_tobeadded_token2;
        Tokensaddedperuser[msg.sender][poolpairnumber][_token1] += amount_tobeadded_token1 ;
        Tokensaddedperuser[msg.sender][poolpairnumber][_token2] += amount_tobeadded_token2 ;
    }

    //Function to remove liquidity 
    // lpamountpercentage may be 25%, 50%, 75%, or maximum 100%
    function Remove_Liquidity (address token1, address token2, uint256 lpamountpercentage, uint256 poolpairnumber) public returns (uint256 , uint256){
        uint256 mydexitalptokens_perpair = GetMydexitalptokens(token1,token2,poolpairnumber);
        uint256 lpremovedamount = (mydexitalptokens_perpair* lpamountpercentage) /100 ;
        require (mydexitalptokens_perpair >= lpremovedamount , "you do not own that amount of liquidity tokens");
        require (lpamountpercentage == 25 || lpamountpercentage == 50  || lpamountpercentage == 75 || lpamountpercentage == 100 , "invalid percentage number");
        (uint256 token1_reserves , uint256 token2_reserves) = GetReservesPerpair(poolpairnumber,token1, token2);
        uint256 totalsupplyofpair = totalsupplyperpair[token1][token2][poolpairnumber];
        uint256 amounttoken1 = ( lpremovedamount * token1_reserves ) / totalsupplyofpair;
        uint256 amounttoken2 = ( lpremovedamount * token2_reserves ) / totalsupplyofpair;
        IERC20(token1).transfer(msg.sender, amounttoken1);
        IERC20(token2).transfer(msg.sender, amounttoken2);
        _burn(msg.sender, lpremovedamount);
        totalsupplyperpair[token1][token2][poolpairnumber] -= lpremovedamount;
        Earned_dexitalptokens_peruser[msg.sender][poolpairnumber][token1][token2] -= lpremovedamount;
        reservesperpairs[poolpairnumber][token1] -= amounttoken1;
        reservesperpairs[poolpairnumber][token2] -= amounttoken2;
        Tokensaddedperuser[msg.sender][poolpairnumber][token1] -= amounttoken1 ;
        Tokensaddedperuser[msg.sender][poolpairnumber][token2] -= amounttoken2 ;
        return (amounttoken1,amounttoken2);
    }

    // Function to find minimum amount of token1 and token2 to be added as liquidity
    function GetMinimumAmountOfTokens_addliquidity (uint256 token1_reserves , uint256 amount1 , uint256 token2_reserves , uint256 amount2) public pure returns (uint256 , uint256){
        uint256 modifiedamount_tobeadded_token1 = BalanceConstantProductFormula (token1_reserves ,token2_reserves, amount2);
        uint256 modifiedamount_tobeadded_token2 = BalanceConstantProductFormula (token2_reserves ,token1_reserves, amount1);
        if (amount1 >= modifiedamount_tobeadded_token1){
            return (modifiedamount_tobeadded_token1 , amount2);
        }
        if (amount2 >= modifiedamount_tobeadded_token2){
            return (amount1 , modifiedamount_tobeadded_token2);
        }
    }

    // Function to calculate the amount needed to be added as liquidity to balance xy=k
    function BalanceConstantProductFormula (uint256 _token1_reserves , uint256 _token2_reserves, uint256 _token1amount) public pure returns (uint256){
        uint256 token2_amount = ((_token1_reserves * 10**4 )/_token2_reserves) * (_token1amount/ 10**4);
        return token2_amount;
    }
    //Pricing functions
    //Function to get the output tokens amount
    function GetOutputTokenAmount(uint256 amountin, uint256 inputreserves, uint256 outputreserves , uint256 feeschoice) public pure returns (uint256){
        // There are three choices for fees 
        // 1 mapped to 0.3% : non-correlated pools fee of 0.3% like WETH/USDC
        // 2 mapped to 0.05% : Stablecoins like DAI/USDC has a fee of 0.05%
        // 3 mapped to 1% :  1% for the non-correlated pairs WBTC/WETH
        require (inputreserves > 0 && outputreserves > 0 , "Dex has no liquidity");
        // Handle choice fees
        // For 0.3% fees
        if (feeschoice == 1){
            uint256 amountin_afterfees = 997 * amountin;
            uint256 inputreserves_modified = 1000 *inputreserves;
            uint256 numerator = outputreserves * amountin_afterfees;
            uint256 denominator =  inputreserves_modified + amountin_afterfees;
            return numerator/denominator;
        }
        // For 0.05% fees
        if (feeschoice == 2){
            uint256 amountin_afterfees = 9995 * amountin;
            uint256 inputreserves_modified = 10000 *inputreserves;
            uint256 numerator = outputreserves * amountin_afterfees;
            uint256 denominator =  inputreserves_modified + amountin_afterfees;
            return numerator/denominator;
        }
          // For 1% fees
        if (feeschoice == 3){
            uint256 amountin_afterfees = 99 * amountin;
            uint256 inputreserves_modified = 100 *inputreserves;
            uint256 numerator = outputreserves * amountin_afterfees;
            uint256 denominator =  inputreserves_modified + amountin_afterfees;
            return numerator/denominator;
        }
    }
    // Function for swapping between two tokens 
    function swaptwotokens (address tokenin, address tokenout , uint256 amountin , uint256 feeschoice,uint256 poolpairnumber ) public returns (uint256){
        require (tokenin != tokenout, "same tokens, error in swap");
        require (IERC20(tokenin).balanceOf(msg.sender) >= amountin , "you do not have these amount of tokens" );
        (uint256 tokenin_reserves , uint256 tokenout_reserves) = GetReservesPerpair(poolpairnumber,tokenin, tokenout);
        uint256 amountout = GetOutputTokenAmount (amountin , tokenin_reserves , tokenout_reserves,feeschoice);
        IERC20(tokenin).transferFrom(msg.sender,address(this), amountin);
        IERC20(tokenout).transfer(msg.sender, amountout);
        reservesperpairs[poolpairnumber][tokenin] += amountin;
        reservesperpairs[poolpairnumber][tokenout] -= amountout;
        return amountout;
    }
     // Function to return the total token reserves found in this contract not per pair
    function GetTokensReserves (address _token1, address _token2) public view returns (uint256 , uint256){
        uint256 token1_reserves = IERC20(_token1).balanceOf(address(this));
        uint256 token2_reserves = IERC20(_token2).balanceOf(address(this));
        return (token1_reserves,token2_reserves);
    }
    // Function to return the reserves of tokens per pair 
    function GetReservesPerpair (uint256 poolpair , address token1, address token2) public view returns (uint256 , uint256){
        uint256 reserve1= reservesperpairs[poolpair][token1];
        uint256 reserve2= reservesperpairs[poolpair][token2];
        return (reserve1,reserve2);
    }
      // Function to return added amount of DexitaLP tokens of users of specific pair
    function GetMydexitalptokens (address token1 , address token2 , uint256 poolpairnumber) public view returns (uint256){
        return Earned_dexitalptokens_peruser[msg.sender][poolpairnumber][token1][token2];
    }
    // Function to return the total supply of each dexita lps per each pair
    function GetTotalSupplyPerPair (address token1 , address token2 , uint256 poolpairnumber) public view returns (uint256){
        return totalsupplyperpair[token1][token2][poolpairnumber];
    }
    // Function to return the added amount of tokens of users in specific pair
    // track contribution of users in liquidity pools
      function GetMyaddedtokensinpools (address token1 , address token2 , uint256 poolpairnumber) public view returns (uint256,uint256){
        uint256 amount1 = Tokensaddedperuser[msg.sender][poolpairnumber][token1];
        uint256 amount2 = Tokensaddedperuser[msg.sender][poolpairnumber][token2];
        return (amount1,amount2);
    }
}