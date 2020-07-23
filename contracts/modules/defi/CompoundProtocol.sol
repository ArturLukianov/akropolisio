pragma solidity ^0.5.12;

import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "../../interfaces/defi/IDefiProtocol.sol";
import "../../interfaces/defi/ICErc20.sol";
import "../../common/Module.sol";
import "./DefiOperatorRole.sol";

/**
 * RAY Protocol support module which works with only one base token
 */
contract CompoundProtocol is Module, DefiOperatorRole, IDefiProtocol {
    uint256 constant MAX_UINT256 = uint256(-1);

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 baseToken;
    uint8 decimals;
    ICErc20 cToken;

    function initialize(address _pool, address _token, address _cToken) public initializer {
        Module.initialize(_pool);
        DefiOperatorRole.initialize(_msgSender());
        baseToken = IERC20(_token);
        cToken = ICErc20(_cToken);
        decimals = ERC20Detailed(_token).decimals();
        baseToken.safeApprove(_cToken, MAX_UINT256);
    }

    function deposit(address token, uint256 amount) public onlyDefiOperator {
        require(token == address(baseToken), "CompoundProtocol: token not supported");
        baseToken.safeTransferFrom(_msgSender(), address(this), amount);
        cToken.mint(amount);
    }

    function deposit(address[] memory tokens, uint256[] memory amounts) public onlyDefiOperator {
        require(tokens.length == 1 && amounts.length == 1, "CompoundProtocol: wrong count of tokens or amounts");
        deposit(tokens[0], amounts[0]);
    }

    function withdraw(address beneficiary, address token, uint256 amount) public onlyDefiOperator {
        require(token == address(baseToken), "CompoundProtocol: token not supported");

        cToken.redeemUnderlying(amount);
        baseToken.safeTransfer(beneficiary, amount);
    }

    function withdraw(address beneficiary, uint256[] memory amounts) public onlyDefiOperator {
        require(amounts.length == 1, "CompoundProtocol: wrong amounts array length");

        cToken.redeemUnderlying(amounts[0]);
        baseToken.safeTransfer(beneficiary, amounts[0]);
    }

    function balanceOf(address token) public returns(uint256) {
        if (token != address(baseToken)) return 0;
        return cToken.balanceOfUnderlying(address(this));
    }
    
    function balanceOfAll() public returns(uint256[] memory) {
        uint256[] memory balances = new uint256[](1);
        balances[0] = balanceOf(address(baseToken));
        return balances;
    }

    function normalizedBalance() public returns(uint256) {
        return normalizeAmount(address(baseToken), balanceOf(address(baseToken)));
    }

    function canSwapToToken(address token) public view returns(bool) {
        return (token == address(baseToken));
    }    

    function supportedTokens() public view returns(address[] memory){
        address[] memory tokens = new address[](1);
        tokens[0] = address(baseToken);
        return tokens;
    }

    function supportedTokensCount() public view returns(uint256) {
        return 1;
    }

    function normalizeAmount(address, uint256 amount) internal view returns(uint256) {
        if (decimals == 18) {
            return amount;
        } else if (decimals > 18) {
            return amount.div(10**(uint256(decimals)-18));
        } else if (decimals > 18) {
            return amount.mul(10**(uint256(decimals)-18));
        }
    }

    function denormalizeAmount(address, uint256 amount) internal view returns(uint256) {
        if (decimals == 18) {
            return amount;
        } else if (decimals > 18) {
            return amount.mul(10**(uint256(decimals)-18));
        } else if (decimals > 18) {
            return amount.div(10**(uint256(decimals)-18));
        }
    }

}