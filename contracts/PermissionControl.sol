// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

contract PermissionControl {
  
  event CreateAccount (
    address indexed owner,
    uint permission,
    uint maxSize
  );
  
  event AddUser (
    address indexed inviter,
    address indexed newUser
  );

  event RemoveUser (
    address indexed manager,
    address indexed removedUser
  );

  event AcceptInvite (
    address indexed user
  );

  event DeclineInvite (
    address indexed user
  );

  /// Constant
  uint constant ADD_ROLE = 1;
  uint constant REMOVE_ROLE = 2;

  /// Enum
  enum CalcCostMethod { Linear, SubLinear, SuperLinear }

  /// @notice Parameters of an Account
  struct Account {
    address owner;
    address[] users;
    CalcCostMethod costMethod;
    uint costParam;
    uint permission;
    uint maxSize;
    bool isActive; 
  }

  struct Invite {
    address inviter;
    bool isInvited;
  }

  /// @notice Account List
  Account[] accounts;

  /// @notice User Address -> Account ID
  mapping(address => uint) userAccounts;

  /// @notice User Address -> Invite
  mapping(address => Invite) userInvites;

  modifier condition(bool _condition) {
    require(_condition);
    _;
  }

  modifier registeredUser(address user) {
    require(accounts[userAccounts[user]].isActive, "This user is not registered");
    _;
  }

  modifier unregisteredUser(address user) {
    require(!(accounts[userAccounts[user]].isActive), "This user is already registered");
    _;
  }

  modifier uninvitedUser (address user) {
    require(!(accounts[userAccounts[user]].isActive), "This user is already registered");
    require(!(userInvites[user].isInvited), "This user is already invited");
    _;
  }

  modifier invitedUser (address user) {
    require(!(accounts[userAccounts[user]].isActive), "This user is already registered");
    require(userInvites[user].isInvited, "This user is not invited");
    _;
  }

  modifier hasAddRole(address user) {
    require(((accounts[userAccounts[user]].permission) & ADD_ROLE) > 0, "This user has no add permission");
    _;
  }

  modifier hasRemoveRole(address user) {
    require(((accounts[userAccounts[user]].permission) & REMOVE_ROLE) > 0, "This user has no remove permission");
    _;
  }

  modifier addableUser (Account storage account) {
    require(account.users.length < account.maxSize, "This account is full");
    _;
  }

  /// @notice Constructor
  constructor() public
  {
    address[] memory users;
    accounts.push(Account(
      address(0x0),
      users,
      CalcCostMethod.Linear,
      0,
      0,
      0,
      false
    )); /// created the unactive account as a default
  }

  /// @notice Calculate the add cost
  function caclCost(Account memory _account) 
    private 
    pure 
    returns (uint) 
  {
    if (_account.costMethod == CalcCostMethod.Linear) {
      return _account.costParam * _account.users.length;
    }
    else if (_account.costMethod == CalcCostMethod.SubLinear) {
      return _account.costParam * (_account.maxSize * _account.maxSize - (_account.maxSize - _account.users.length) * (_account.maxSize - _account.users.length));
    }
    else if (_account.costMethod == CalcCostMethod.SuperLinear) {
      return _account.costParam * _account.users.length * _account.users.length;
    }

    return 0;
  }

  /**
    @notice Creates a new account for a given garment
    @dev Only the unregistered user can create the account
    @param _costMethod Cost Calculate Method
    @param _costParam Cost Calculate Param 
    @param _maxSize Maximum size of users
    */
  function createAccount(
    CalcCostMethod _costMethod,
    uint _costParam,
    uint _permission,
    uint _maxSize
  ) 
    public 
    unregisteredUser(msg.sender) 
  {
    address[] memory users = new address[](1);
    users[0] = msg.sender;

    userAccounts[msg.sender] = accounts.length;
    accounts.push(Account(
      msg.sender,
      users,
      _costMethod,
      _costParam,
      _permission,
      _maxSize,
      true
    ));
    
    emit CreateAccount(msg.sender, _permission, _maxSize);
  }

  /**
    @notice Invite a new user
    @dev Only can invite the unregistered user
    @param _newUser New user address
    */
  function addUser(
    address _newUser
  ) 
    external 
    uninvitedUser(_newUser)
    addableUser (accounts[userAccounts[msg.sender]])
    hasAddRole(msg.sender) 
  {
    userInvites[_newUser] = Invite(
      msg.sender,
      true
    );

    emit AddUser(msg.sender, _newUser);
  }

  /**
    @notice Accept the invite
    @dev This user should be invited
    */
  function acceptInvite() 
    external
    invitedUser(msg.sender)
    addableUser (accounts[userAccounts[userInvites[msg.sender].inviter]])
    payable
  {
  
    require(transfer(msg.sender, msg.value), "Transfer failed");

    uint accountId = userAccounts[userInvites[msg.sender].inviter];
    Account storage account = accounts[accountId];
    account.users.push(msg.sender);
    userAccounts[msg.sender] = accountId;
    userInvites[msg.sender].isInvited = false;

    emit AcceptInvite(msg.sender);
  }

  /**
    @notice Accept the invite
    @dev This user should be invited
    */
  function declineInvite() 
    external
    invitedUser(msg.sender)
  {
    userInvites[msg.sender].isInvited = false;

    emit DeclineInvite(msg.sender);
  }

  /**
    @notice Transfer the cost
    @dev This user should be a unregistered user
    */
  function transfer(address _sender, uint _amount) 
    private
    returns(bool)
  {
    /// @TODO

    return true;
  }

  /**
    @notice Remove a user
    @dev Only can remove the registered user
    @param _removableUser Removable user address
    */
  function removeUser(
    address _removableUser
  ) 
    external 
    registeredUser(_removableUser) 
    hasRemoveRole(msg.sender) 
  {
    /// can't remove the account owner
    require(_removableUser != accounts[userAccounts[_removableUser]].owner, "Can't remove the owner");
    
    userAccounts[_removableUser] = 0;

    emit RemoveUser(msg.sender, _removableUser);
  }
}
