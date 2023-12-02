import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Array "mo:base/Array";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Types "Types";
import Member "member";
import Account "account";

import Iter "mo:base/Iter";
// import Hash "mo:base/Hash";

actor ICPTutorials = {

  //let DAO = Principal.fromText("aaaaa-aa");
  public type Tutorial = Types.Tutorial;
  public type Publication = Types.Publication;
  public type Account  = Account.Account;
  public type User = Member.Member;
  public type SignUpResult = Result.Result<User,Member.SignUpErrors>;
  public type PublishResult = Result.Result<Publication, Text>;
  public type TutoId = Nat;
  public type UserId = Nat;

  stable var currentUserId = 0;
  stable var currentTutorialId = 0;
  stable var admins: [Principal] = [];

  //let ledger = HashMap.HashMap<Account, Nat>(1, Account.accountsEqual, Account.accountsHash);
  let userIds = HashMap.HashMap<Principal,UserId>(1, Principal.equal, Principal.hash);
  let users = HashMap.HashMap<UserId,User>(1, Nat.equal, Nat32.fromNat);
  
  let blackList = HashMap.HashMap<Principal,()>(0, Principal.equal, Principal.hash);
  
  var incomingPublications = HashMap.HashMap<TutoId,Publication>(1, Types.tutoIdEqual, Types.tutoIdHash);
  var aprovedPublications = HashMap.HashMap<TutoId,Publication>(1, Types.tutoIdEqual, Types.tutoIdHash);

  func inBlackList(p: Principal): Bool{
    return switch (blackList.get(p)) {
      case null{false};
      case _{true};
    };
  };
  func isAdmin(p: Principal): Bool{
    for(a in admins.vals()){
      if(a == p){ return true};
    };
    false;
  };

  public shared ({caller}) func signUp(name: Text, birthdate: ?Nat, sex: ?Member.Sex): async SignUpResult{
    //TODO: Validación de campos
    if(Principal.isAnonymous(caller)){ return #err(#CallerAnnonymous)};
    if(inBlackList(caller)){ return #err(#InBlackList)};
    switch(userIds.get(caller)){
      case null{
        let timestamp = Time.now() / 1_000_000_000: Int; //Timestamp in seconds
        userIds.put(caller,currentUserId);
        
        let newMember = {
          name;
          birthdate; //DDMMAAAA
          admissionDate = timestamp; 
          sex;
        };
        users.put(currentUserId,newMember);
        currentUserId += 1;
        return #ok(newMember);
      };
      case (?member){
        return #err(#IsAlreadyAMember);
      };
    };    
  };

  func isUser(p: Principal): Bool{
    return switch (userIds.get(p)){
      case null{false};
      case _{true};
    };
  };
  public shared ({caller}) func publish(content: Tutorial): async PublishResult{
    switch(userIds.get(caller)){
      case null { return #err("Caller is not a member")};
      case (?userId) {
        let date = Time.now() / 1_000_000_000: Int;
        let pub = {
          autor = userId;
          date;
          content;
        };
        incomingPublications.put(currentTutorialId, pub);
        currentTutorialId += 1;
        #ok(pub);
      };
    };
  };

  public shared ({caller}) func aprovePublication(id: Nat):async Result.Result<(), Text> {
    // assert (caller != DAO);
    assert (isAdmin(caller));
    switch (incomingPublications.remove(id)){
      case null{return #err("Tutorial id does not exist")};
      case (?tuto){
        aprovedPublications.put(id, tuto);
        return #ok();
      };
    };    
  };

  public shared ({caller}) func rejectPublication(id: Nat):async Result.Result<(), Text> {
    //assert (caller != DAO);
    assert (isAdmin(caller));
    return switch (incomingPublications.remove(id)){
      case null{#err("Tutorial id does not exist")};
      case (_){#ok()};
    };    
  };

  public shared ({caller}) func getIncomingPublication(): async [Publication]{
    //assert (caller != DAO);
    assert (isAdmin(caller));
    return Iter.toArray(aprovedPublications.vals());
  };

  public query func getAprovedPublication(): async [Publication]{
    return Iter.toArray(aprovedPublications.vals());
  };
  
  public query func getPubFromUser(userId: Nat): async [Publication]{
    var pubs = Iter.toArray(aprovedPublications.vals());
    Array.filter<Publication>(pubs, func x: Bool {x.autor == userId});  
  };

};
