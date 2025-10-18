// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title VoteAndReward — simple voting + token reward system
/// @notice No imports, no constructor. Owner is set at deployment via tx.origin in state initializer.
contract VoteAndReward {
    // --- Token state (simple ERC20-like) ---
    string public constant name = "VoteToken";
    string public constant symbol = "VOTE";
    uint8 public constant decimals = 18;

    uint256 public totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // --- Voting state ---
    struct Proposal {
        string description;
        uint256 voteCount;
        bool exists;
    }

    mapping(uint256 => Proposal) public proposals;
    uint256 public proposalCount;

    // track if an address has voted on a proposal
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    // owner captured at deployment (no constructor)
    address public owner = tx.origin;

    // reward given to each voter (in token smallest units)
    uint256 public rewardAmount = 10 * (10 ** uint256(decimals));

    // --- Events ---
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed ownerAddr, address indexed spender, uint256 value);
    event ProposalCreated(uint256 indexed proposalId, string description);
    event Voted(uint256 indexed proposalId, address indexed voter);
    event RewardAmountChanged(uint256 indexed oldAmount, uint256 indexed newAmount);

    // --- Modifiers ---
    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    // --- Token functions (minimal) ---
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function allowance(address ownerAddr, address spender) external view returns (uint256) {
        return _allowances[ownerAddr][spender];
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 allowed = _allowances[from][msg.sender];
        require(allowed >= amount, "allowance too low");
        _allowances[from][msg.sender] = allowed - amount;
        _transfer(from, to, amount);
        return true;
    }

    // --- Internal token helpers ---
    function _transfer(address from, address to, uint256 amount) internal {
        require(to != address(0), "transfer to zero");
        require(_balances[from] >= amount, "insufficient balance");
        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "mint to zero");
        totalSupply += amount;
        _balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    // --- Voting functions ---
    /// @notice Owner creates a proposal. Supply description string.
    function createProposal(string calldata description) external onlyOwner {
        require(bytes(description).length > 0, "empty description");
        uint256 id = proposalCount;
        proposals[id] = Proposal({description: description, voteCount: 0, exists: true});
        proposalCount = id + 1;
        emit ProposalCreated(id, description);
    }

    /// @notice Vote for a proposal id. Reward tokens are minted to voter.
    function vote(uint256 proposalId) external {
        require(proposals[proposalId].exists, "proposal not found");
        require(!hasVoted[proposalId][msg.sender], "already voted");

        hasVoted[proposalId][msg.sender] = true;
        proposals[proposalId].voteCount += 1;

        // reward the voter
        _mint(msg.sender, rewardAmount);

        emit Voted(proposalId, msg.sender);
    }

    /// @notice Owner can change how many tokens a voter receives per vote.
    function setRewardAmount(uint256 newAmount) external onlyOwner {
        uint256 old = rewardAmount;
        rewardAmount = newAmount;
        emit RewardAmountChanged(old, newAmount);
    }

    // --- Read helpers for proposals ---
    function proposalDescription(uint256 proposalId) external view returns (string memory) {
        require(proposals[proposalId].exists, "proposal not found");
        return proposals[proposalId].description;
    }

    function proposalVotes(uint256 proposalId) external view returns (uint256) {
        require(proposals[proposalId].exists, "proposal not found");
        return proposals[proposalId].voteCount;
    }

    // --- Recovery / admin helpers (owner only) ---
    /// @notice Owner may burn tokens from an address (careful).
    function burnFrom(address account, uint256 amount) external onlyOwner {
        require(_balances[account] >= amount, "insufficient balance");
        _balances[account] -= amount;
        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    /// @notice Transfer contract ownership to another address.
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "zero address");
        owner = newOwner;
    }
}

