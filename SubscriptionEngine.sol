// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title SubscriptionEngine
 * @dev Manages recurring pull-payments for Web3 services.
 */
contract SubscriptionEngine is Ownable, ReentrancyGuard {
    struct Plan {
        uint256 amount;
        uint256 frequency; // in seconds
        bool active;
    }

    struct Subscription {
        uint256 planId;
        uint256 lastPayment;
        bool active;
    }

    IERC20 public immutable paymentToken;
    mapping(uint256 => Plan) public plans;
    mapping(address => Subscription) public subscriptions;
    uint256 public nextPlanId;

    event PlanCreated(uint256 indexed planId, uint256 amount, uint256 frequency);
    event Subscribed(address indexed user, uint256 indexed planId);
    event PaymentExecuted(address indexed user, uint256 amount, uint256 timestamp);

    constructor(address _token) Ownable(msg.sender) {
        paymentToken = IERC20(_token);
    }

    function createPlan(uint256 _amount, uint256 _frequency) external onlyOwner {
        plans[nextPlanId] = Plan(_amount, _frequency, true);
        emit PlanCreated(nextPlanId, _amount, _frequency);
        nextPlanId++;
    }

    function subscribe(uint256 _planId) external {
        require(plans[_planId].active, "Plan not active");
        subscriptions[msg.sender] = Subscription(_planId, 0, true);
        emit Subscribed(msg.sender, _planId);
    }

    /**
     * @dev Called by provider to pull the subscription fee.
     */
    function executePayment(address _user) external nonReentrant {
        Subscription storage sub = subscriptions[_user];
        Plan storage plan = plans[sub.planId];

        require(sub.active, "No active subscription");
        require(block.timestamp >= sub.lastPayment + plan.frequency, "Too early for next payment");

        sub.lastPayment = block.timestamp;
        require(
            paymentToken.transferFrom(_user, owner(), plan.amount),
            "Transfer failed"
        );

        emit PaymentExecuted(_user, plan.amount, block.timestamp);
    }

    function cancelSubscription() external {
        subscriptions[msg.sender].active = false;
    }
}
