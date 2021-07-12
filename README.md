# Permission Management

## Introduction

Build an on-chain system of managing permissions. Their purpose and actions are outside
the scope of the assignment. Any account can register 1 or more users and grants
permission of who can or cannot add or remove users in that hierarchy except that they
cannot remove the account who created the hierarchy. Also, the user inherits the same
permission that of the account created by them.
There are a maximum number of users in any hierarchy. The cost of adding a user varies
directly as the size of the hierarchy so, for example, adding a user to a hierarchy of size 5 is
more expensive than to add to a size of 3.
The exact variation is up to you so it can be linear, sublinear, or superlinear.

## Assumption

- Assume the hierarchy as the user list ( There is no description about the hierarchy )
- Leave the implementation of the cost flow ( There is no description about the cost flow )
- Assume the *add user* as the *invite user* ( The invited user can accept or decline the invite )


## Installation

First, we init truffle project.

```bash
# To test in the local net, 
truffle migrate

# To test in the truffle
truffle test
```