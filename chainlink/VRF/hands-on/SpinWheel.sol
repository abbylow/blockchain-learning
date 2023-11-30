// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

/**
 * @notice A Chainlink VRF consumer which uses randomness to mimic the wheel spinning 
 * Each creator can create multiple wheels with options (2 to 10 options)
 * Each wheel can be spinned for multiple times
 * Each spin will only call VRF once
 */

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract VRFD20 is VRFConsumerBaseV2 {
    uint256 private constant ROLL_IN_PROGRESS = 42;

    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 s_subscriptionId;

    // Sepolia coordinator. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 s_keyHash =
        0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 40,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 40000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 1 random value in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords = 1;

    uint256 public constant MAX_NUM_OF_OPTIONS = 10;
    uint256 public numOfWheels = 0;
    
    struct Wheel {
        uint256 id;
        uint256 numOfOptions;
        string[] options;
    }

    struct Spin {
        uint256 requestId;
        uint256 wheelId;
        uint256 result;
    }

    mapping(address => uint256[]) public creatorToWheelIds;
    Wheel[] public wheels;
    mapping(uint256 => uint256[]) public wheelIdToSpinIds;
    mapping(uint256 => Spin) public requestIdToSpin;
    
    event WheelCreated(uint256 indexed id, address indexed creator);
    event WheelSpinned(uint256 indexed requestId);
    event WheelStopped(uint256 indexed requestId, uint256 result);

    error ExceedOptionMaxLimit(uint256 numOfOptions);
    error LessThanTwoOptions(uint256 numOfOptions);
    error InvalidWheelId(uint256 wheelId);

    /**
     * @notice Constructor inherits VRFConsumerBaseV2
     *
     * @dev NETWORK: Sepolia
     *
     * @param subscriptionId subscription id that this consumer contract can use
     */
    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_subscriptionId = subscriptionId;
    }


    /**
     * @notice Create wheel
     *
     * @param options string[] wheel options (2 to 10 options)
     */
    function createWheel(
        string[] calldata options
    ) public {
        uint256 optionLen = options.length;

        if(optionLen < 2) {
            revert LessThanTwoOptions({numOfOptions: optionLen});
        }
        if(optionLen > MAX_NUM_OF_OPTIONS) {
            revert ExceedOptionMaxLimit({numOfOptions: optionLen});
        }

        numOfWheels++;
        creatorToWheelIds[msg.sender].push(numOfWheels);
        wheels.push(Wheel(numOfWheels, optionLen, options));
        
        emit WheelCreated(numOfWheels, msg.sender);
    }

    /**
     * @notice Requests randomness
     * @dev Warning: if the VRF response is delayed, avoid calling requestRandomness repeatedly
     * as that would give miners/VRF operators latitude about which VRF response arrives first.
     * @dev You must review your implementation details with extreme care.
     *
     * @param wheelId uint256
     */
    function spinWheel(
        uint256 wheelId
    ) public returns (uint256 requestId) {
        if (wheelId > numOfWheels || wheelId == 0) revert InvalidWheelId(wheelId);
        
        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            s_keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        requestIdToSpin[requestId] = Spin(requestId, wheelId, ROLL_IN_PROGRESS);
        wheelIdToSpinIds[wheelId].push(requestId);
        
        emit WheelSpinned(requestId);
    }

    /**
     * @notice Callback function used by VRF Coordinator to return the random number to this contract.
     *
     * @dev Some action on the contract state should be taken here, like storing the result.
     * @dev WARNING: take care to avoid having multiple VRF requests in flight if their order of arrival would result
     * in contract states with different outcomes. Otherwise miners or the VRF operator would could take advantage
     * by controlling the order.
     * @dev The VRF Coordinator will only send this function verified responses, and the parent VRFConsumerBaseV2
     * contract ensures that this method only receives randomness from the designated VRFCoordinator.
     *
     * @param requestId uint256 vrf request id
     * @param randomWords  uint256[] The random result returned by the oracle.
     */
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        Spin memory spin = requestIdToSpin[requestId];

        if (spin.wheelId == 0) {
            revert InvalidWheelId(spin.wheelId);
        }

        Wheel memory wheel = wheels[spin.wheelId - 1];
        if (wheel.id == 0) {
            revert InvalidWheelId(wheel.id);
        }

        uint256 value = (randomWords[0] % wheel.numOfOptions) + 1;
        requestIdToSpin[requestId].result = value;
        emit WheelStopped(requestId, value);
    }

    /**
     * @notice Get the wheel ids created by the user
     * @param creator address
     * @return house as a string
     */
    function wheelsCreatedBy(address creator) public view returns (uint256[] memory) {
        return creatorToWheelIds[creator];
    }

    /**
     * @notice Get the wheel by id
     * @param wheelId uint256
     * @return wheel
     */
    function wheelById(uint256 wheelId) public view returns (Wheel memory) {
        if (wheelId > numOfWheels || wheelId == 0) revert InvalidWheelId(wheelId);
        return wheels[wheelId - 1];
    }


    /**
     * @notice Get the spins by wheel id
     * @param wheelId uint256
     * @return spin ids
     */
    function spinsByWheelId(uint256 wheelId) public view returns (uint256[] memory) {
        return wheelIdToSpinIds[wheelId];
    }

    /**
     * @notice Get the spin by id (spin id is the vrf request id)
     * @param requestId uint256
     * @return spin 
     */
    function spinByRequestId(uint256 requestId) public view returns (Spin memory) {
        return requestIdToSpin[requestId];
    }
}
