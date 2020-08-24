@echo off
rem === DEFINE MODULES ===
rem ==== External ====

rem ===== Tokens ====
SET EXT_TOKEN_DAI=0x6b175474e89094c44da98b954eedeac495271d0f
SET EXT_TOKEN_USDC=0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48
SET EXT_TOKEN_AKRO=0x8ab7404063ec4dbcfd4598215992dc3f8ec853d7

rem ===== Compound ====
SET EXT_COMPOUND_CTOKEN_DAI=0x5d3a536e4d6dbd6114cc1ead35777bab948e3643
SET EXT_COMPOUND_CTOKEN_USDC=0x39aa39c021dfbae8fac545936693ac917d5e7563
SET EXT_COMPOUND_COMPTROLLER=0x3d9819210a31b4961b30ef54be2aed79b9c9cd3b

rem ===== Curve.Fi ====
SET EXT_CURVEFY_Y_DEPOSIT=0xbBC81d23Ea2c3ec7e56D39296F0cbB648873a5d3
SET EXT_CURVEFY_Y_GAUGE=0xFA712EE4788C042e2B7BB55E6cb8ec569C4530c1
SET EXT_CURVEFY_SBTC_DEPOSIT=
SET EXT_CURVEFY_SBTC_GAUGE=
SET EXT_CURVEFY_SUSD_DEPOSIT=0xFCBa3E75865d2d561BE8D220616520c171F12851
SET EXT_CURVEFY_SUSD_GAUGE=0xa90996896660decc6e997655e065b23788857849
SET EXT_CURVEFY_BUSD_DEPOSIT=0xb6c057591E073249F2D9D88Ba59a46CFC9B59EdB
SET EXT_CURVEFY_BUSD_GAUGE=0x69Fb7c45726cfE2baDeE8317005d3F94bE838840

rem ==== Akropolis ====
SET MODULE_POOL=0x4C39b37f5F20a0695BFDC59cf10bd85a6c4B7c30
SET MODULE_ACCESS=0x5fFcf7da7BdC49CA8A2E7a542BD59dC38228Dd45
SET MODULE_SAVINGS=0x73fC3038B4cD8FfD07482b92a52Ea806505e5748
SET MODULE_STAKING=0x3501Ec11d205fa249f2C42f5470e137b529b35D0

SET PROTOCOL_CURVEFY_Y=0x7967adA2A32A633d5C055e2e075A83023B632B4e
SET POOL_TOKEN_CURVEFY_Y=0x2AFA3c8Bf33E65d5036cD0f1c3599716894B3077

SET PROTOCOL_CURVEFY_SBTC=
SET POOL_TOKEN_CURVEFY_SBTC=

SET PROTOCOL_CURVEFY_SUSD=0x91d7b9a8d2314110D4018C88dBFDCF5E2ba4772E
SET POOL_TOKEN_CURVEFY_SUSD=0x520d25b08080296db66fd9f268ae279b66a8effb

SET PROTOCOL_CURVEFY_BUSD=0xEaE1A8206F68a7ef629e85fc69E82CFD36E83BA4
SET POOL_TOKEN_CURVEFY_BUSD=0x8367Af78444C5B57Bc1cF38dED331d03558e67Bb

SET PROTOCOL_COMPOUND_DAI=0x08DDB58D31C08242Cd444BB5B43F7d2C6bcA0396
SET POOL_TOKEN_COMPOUND_DAI=0x9Fca734Bb62C20D2cF654705b8fbf4F49FF5cC31

SET PROTOCOL_COMPOUND_USDC=0x9984D588EF2112894a0513663ba815310D383E3c
SET POOL_TOKEN_COMPOUND_USDC=0x5Ad76E93a3a852C9af760dA3FdB7983C265d8997

rem === ACTION ===
echo call npx oz create CurveFiProtocol_BUSD --network mainnet --init "initialize(address _pool)" --args %MODULE_POOL%
echo call npx oz create PoolToken_CurveFi_BUSD --network mainnet --init "initialize(address _pool)" --args %MODULE_POOL%
echo call npx oz send-tx --to %PROTOCOL_CURVEFY_BUSD% --network mainnet --method setCurveFi --args "%EXT_CURVEFY_BUSD_DEPOSIT%, %EXT_CURVEFY_BUSD_GAUGE%"
echo call npx oz send-tx --to %MODULE_SAVINGS% --network mainnet --method registerProtocol --args "%PROTOCOL_CURVEFY_BUSD%, %POOL_TOKEN_CURVEFY_BUSD%"
echo call npx oz send-tx --to %PROTOCOL_CURVEFY_BUSD% --network mainnet --method addDefiOperator --args %MODULE_SAVINGS%
echo call npx oz send-tx --to %POOL_TOKEN_CURVEFY_BUSD% --network mainnet --method addMinter --args %MODULE_SAVINGS%
goto :done

:init
echo INIT PROJECT, ADD CONTRACTS
call npx oz init
call npx oz add Pool AccessModule SavingsModule StakingPool
call npx oz add CompoundProtocol_DAI PoolToken_Compound_DAI
call npx oz add CompoundProtocol_USDC PoolToken_Compound_USDC
rem call npx oz add CurveFiProtocol_Y PoolToken_CurveFiY
rem call npx oz add CurveFiProtocol_SBTC PoolToken_CurveFi_SBTC
call npx oz add CurveFiProtocol_SUSD PoolToken_CurveFi_SUSD
call npx oz add CurveFiProtocol_BUSD PoolToken_CurveFi_BUSD
goto :done

:createPool
echo CREATE POOL
call npx oz create Pool --network mainnet --init
goto :done

:createModules
echo CREATE MODULES
call npx oz create AccessModule --network mainnet --init "initialize(address _pool)" --args %MODULE_POOL%
call npx oz create SavingsModule --network mainnet --init "initialize(address _pool)" --args %MODULE_POOL%
call npx oz create StakingPool --network mainnet --init "initialize(address _pool,address _stakingToken, uint256 _defaultLockInDuration)" --args "%MODULE_POOL%, %EXT_TOKEN_AKRO%, 0"
echo CREATE PROTOCOLS AND TOKENS
echo CREATE Compound DAI
call npx oz create CompoundProtocol_DAI --network mainnet --init "initialize(address _pool, address _token, address _cToken, address _comptroller)" --args "%MODULE_POOL%, %EXT_TOKEN_DAI%, %EXT_COMPOUND_CTOKEN_DAI%, %EXT_COMPOUND_COMPTROLLER%"
call npx oz create PoolToken_Compound_DAI --network mainnet --init "initialize(address _pool)" --args %MODULE_POOL%
echo CREATE Compound USDC
call npx oz create CompoundProtocol_USDC --network mainnet --init "initialize(address _pool, address _token, address _cToken, address _comptroller)" --args "%MODULE_POOL%, %EXT_TOKEN_USDC%, %EXT_COMPOUND_CTOKEN_USDC%, %EXT_COMPOUND_COMPTROLLER%"
call npx oz create PoolToken_Compound_USDC --network mainnet --init "initialize(address _pool)" --args %MODULE_POOL%
echo CREATE Curve.Fi Y
call npx oz create CurveFiProtocol_Y --network mainnet --init "initialize(address _pool)" --args %MODULE_POOL%
call npx oz create PoolToken_CurveFi_Y --network mainnet --init "initialize(address _pool)" --args %MODULE_POOL%
rem echo CREATE Curve.Fi SBTC
rem call npx oz create CurveFiProtocol_SBTC --network mainnet --init "initialize(address _pool)" --args %MODULE_POOL%
rem call npx oz create PoolToken_CurveFi_SBTC --network mainnet --init "initialize(address _pool)" --args %MODULE_POOL%
echo CREATE Curve.Fi SUSD
call npx oz create CurveFiProtocol_SUSD --network mainnet --init "initialize(address _pool)" --args %MODULE_POOL%
call npx oz create PoolToken_CurveFi_SUSD --network mainnet --init "initialize(address _pool)" --args %MODULE_POOL%
echo CREATE Curve.Fi BUSD
call npx oz create CurveFiProtocol_BUSD --network mainnet --init "initialize(address _pool)" --args %MODULE_POOL%
call npx oz create PoolToken_CurveFi_BUSD --network mainnet --init "initialize(address _pool)" --args %MODULE_POOL%
goto :done

:empty
rem fixes "can not find addModules" error 
goto :done

:addModules
echo SETUP POOL: CALL FOR ALL MODULES (set)
call npx oz send-tx --to %MODULE_POOL% --network mainnet --method set --args "access, %MODULE_ACCESS%, false"
call npx oz send-tx --to %MODULE_POOL% --network mainnet --method set --args "savings, %MODULE_SAVINGS%, false"
call npx oz send-tx --to %MODULE_POOL% --network mainnet --method set --args "staking, %MODULE_STAKING%, false"
goto :done

:setupProtocols
echo SETUP OTHER CONTRACTS
call npx oz send-tx --to %PROTOCOL_CURVEFY_Y% --network mainnet --method setCurveFi --args "%EXT_CURVEFY_Y_DEPOSIT%, %EXT_CURVEFY_Y_GAUGE%"
rem call npx oz send-tx --to %PROTOCOL_CURVEFY_SBTC% --network mainnet --method setCurveFi --args "%EXT_CURVEFY_SBTC_DEPOSIT%, %EXT_CURVEFY_SBTC_GAUGE%"
call npx oz send-tx --to %PROTOCOL_CURVEFY_SUSD% --network mainnet --method setCurveFi --args "%EXT_CURVEFY_SUSD_DEPOSIT%, %EXT_CURVEFY_SUSD_GAUGE%"
call npx oz send-tx --to %PROTOCOL_CURVEFY_BUSD% --network mainnet --method setCurveFi --args "%EXT_CURVEFY_BUSD_DEPOSIT%, %EXT_CURVEFY_BUSD_GAUGE%"
goto :done

:addProtocols
echo ADD PROTOCOLS
call npx oz send-tx --to %MODULE_SAVINGS% --network mainnet --method registerProtocol --args "%PROTOCOL_COMPOUND_DAI%, %POOL_TOKEN_COMPOUND_DAI%"
call npx oz send-tx --to %MODULE_SAVINGS% --network mainnet --method registerProtocol --args "%PROTOCOL_COMPOUND_USDC%, %POOL_TOKEN_COMPOUND_USDC%"
call npx oz send-tx --to %MODULE_SAVINGS% --network mainnet --method registerProtocol --args "%PROTOCOL_CURVEFY_Y%, %POOL_TOKEN_CURVEFY_Y%"
rem call npx oz send-tx --to %MODULE_SAVINGS% --network mainnet --method registerProtocol --args "%PROTOCOL_CURVEFY_SBTC%, %POOL_TOKEN_CURVEFY_SBTC%"
call npx oz send-tx --to %MODULE_SAVINGS% --network mainnet --method registerProtocol --args "%PROTOCOL_CURVEFY_SUSD%, %POOL_TOKEN_CURVEFY_SUSD%"
call npx oz send-tx --to %MODULE_SAVINGS% --network mainnet --method registerProtocol --args "%PROTOCOL_CURVEFY_BUSD%, %POOL_TOKEN_CURVEFY_BUSD%"
goto :done

:setupOperators
echo SETUP OPERATORS FOR PROTOCOLS
call npx oz send-tx --to %PROTOCOL_COMPOUND_DAI% --network mainnet --method addDefiOperator --args %MODULE_SAVINGS%
call npx oz send-tx --to %PROTOCOL_COMPOUND_USDC% --network mainnet --method addDefiOperator --args %MODULE_SAVINGS%
call npx oz send-tx --to %PROTOCOL_CURVEFY_Y% --network mainnet --method addDefiOperator --args %MODULE_SAVINGS%
rem call npx oz send-tx --to %PROTOCOL_CURVEFY_SBTC% --network mainnet --method addDefiOperator --args %MODULE_SAVINGS%
call npx oz send-tx --to %PROTOCOL_CURVEFY_SUSD% --network mainnet --method addDefiOperator --args %MODULE_SAVINGS%
call npx oz send-tx --to %PROTOCOL_CURVEFY_BUSD% --network mainnet --method addDefiOperator --args %MODULE_SAVINGS%
echo SETUP MINTERS FOR POOL TOKENS
call npx oz send-tx --to %POOL_TOKEN_COMPOUND_DAI% --network mainnet --method addMinter --args %MODULE_SAVINGS%
call npx oz send-tx --to %POOL_TOKEN_COMPOUND_USDC% --network mainnet --method addMinter --args %MODULE_SAVINGS%
call npx oz send-tx --to %POOL_TOKEN_CURVEFY_Y% --network mainnet --method addMinter --args %MODULE_SAVINGS%
rem call npx oz send-tx --to %POOL_TOKEN_CURVEFY_SBTC% --network mainnet --method addMinter --args %MODULE_SAVINGS%
rem call npx oz send-tx --to %POOL_TOKEN_CURVEFY_SUSD% --network mainnet --method addMinter --args %MODULE_SAVINGS%
call npx oz send-tx --to %POOL_TOKEN_CURVEFY_BUSD% --network mainnet --method addMinter --args %MODULE_SAVINGS%
goto :done

:done
echo DONE