import { v4 as uuid } from "uuid";
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

class AuthService {
  constructor({ mongo }) {
    this.mongo = mongo;
    this.errorCodes = {
      USER_ALREADY_EXISTS: {
        code: 400,
        message: "User with this username/email already exists"
      },
      USER_NOT_FOUND: {
        code: 404,
        message: "User not found"
      },
      INVALID_ROLE: {
        code: 400,
        message: "Given role is invalid"
      },
      INVALID_REF: {
        code: 400,
        message: "Given reference ID is invalid"
      },
      INVALID_CREDENTIAL: {
        code: 400,
        message: "Invalid credentials"
      }
    };
  }

  createUser({ username, email, password, role, refId }) {
    const existingUser = this.mongo.users.find(u => u.username == username || u.email == email);
    if(existingUser) throw 'USER_ALREADY_EXISTS';
    if(role != 'admin' && !['student', 'teacher'].includes(role)) throw 'INVALID_ROLE';
    if(role != 'admin' && !this.mongo[`${role}s`].find(s => s._id == refId && !s.removeContent)) throw 'INVALID_REF';

    const user = {
      _id: uuid().replace(/\-/g, ''),
      username,
      email,
      role,
      refId,
      createdAt: Date.now(),
      updatedAt: Date.now(),
      isNewData: true
    };
    this.mongo.users.push({ ...user, password: bcrypt.hashSync(password, 10) });
    return user;
  }

  signInUser({ username, password }) {
    const user = this.mongo.users.find(u => u.username == username || u.email == username);
    if(!user || !bcrypt.compareSync(password, user.password)) throw 'INVALID_CREDENTIAL';
    const token = jwt.sign({ uid: user._id }, process.env.ACCESS_TOKEN);
    this.mongo.tokens.push({ token, uid: user._id, _id: uuid().replace(/\-/g, ''), isNewData: true });
    return { token };
  }

  signOutUser({ token }) {
    const tokenIndex = this.mongo.tokens.findIndex(t => t.token == token);
    if(tokenIndex < 0) return true;
    this.mongo.tokens[tokenIndex] = {_id: this.mongo.tokens[tokenIndex]._id, removeContent: true};
    return true;
  }

  deleteUser({ id }) {
    const userIndex = this.mongo.users.findIndex(u => u._id == id && !u.removeContent);
    if(userIndex < 0) throw 'USER_NOT_FOUND';
    const tokenIndex = this.mongo.tokens.findIndex(t => t.uid != id);
    this.mongo.users[userIndex] = {_id: id, removeContent: true};
    this.mongo.tokens[tokenIndex] = {_id: this.mongo.tokens[tokenIndex]._id, removeContent: true};
    return true;
  }

  verifyToken({ token }) {
    try {
      if(jwt.verify(token, process.env.ACCESS_TOKEN) && this.mongo.tokens.find(t => t.token == token)) return true;
      return false;
    } catch(e) {
      return false;
    }
  }

  getUser({ token, id }) {
    let user, ref;
    if(token) {
      const existToken = this.mongo.tokens.find(t => t.token == token);
      if(!existToken) throw 'INVALID_CREDENTIAL';
      user = this.mongo.users.find(u => u._id == existToken.uid && !u.removeContent);
    } else if(id) {
      user = this.mongo.users.find(u => u._id == id && !u.removeContent);
    } else {
      throw 'INVALID_CREDENTIAL';
    }

    if(!user) throw 'INVALID_CREDENTIAL';
    if(user.role != "admin") {
      ref = this.mongo[`${user.role}s`].find(s => s._id == user.refId && !u.removeContent);
      if(!ref) throw 'INVALID_CREDENTIAL';
      return {...user, ...ref};
    }
    return user;
  }
}

export {
  AuthService as default
};
