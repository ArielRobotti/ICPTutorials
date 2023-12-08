import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Array "mo:base/Array";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Types "Types";
import User "user";
import Account "account";

import Iter "mo:base/Iter";
import Text "mo:base/Text";
// import Hash "mo:base/Hash";

shared ({caller}) actor class ICPTutorials() = {

  //let DAO = Principal.fromText("aaaaa-aa");
  public type Tutorial = Types.Tutorial;
  public type Publication = Types.Publication;
  public type Account  = Account.Account;
  public type User = User.User;
  public type SignUpResult = Result.Result<User,User.SignUpErrors>;
  public type PublishResult = Result.Result<Publication, Text>;
  public type TutoId = Nat;
  public type UserId = Nat;
  public type UserSettings = User.UserSettings;

  stable var currentUserId = 0;
  stable var currentTutorialId = 0;
  stable var admins: [Principal] = [caller];

  //let ledger = HashMap.HashMap<Account, Nat>(1, Account.accountsEqual, Account.accountsHash);
  let userIds = HashMap.HashMap<Principal,UserId>(1, Principal.equal, Principal.hash);
  let users = HashMap.HashMap<UserId,User>(1, Nat.equal, Nat32.fromNat);
  
  let blackList = HashMap.HashMap<Principal,()>(0, Principal.equal, Principal.hash);
  
  var incomingPublications = HashMap.HashMap<TutoId,Publication>(1, Types.tutoIdEqual, Types.tutoIdHash);
  var aprovedPublications = HashMap.HashMap<TutoId,Publication>(1, Types.tutoIdEqual, Types.tutoIdHash);

  public query func getUsers(): async [User]{
    Iter.toArray<User>(users.vals());
  };

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

  public shared ({caller}) func addAdmin(p: Text): async Bool{
    assert(isAdmin(caller));
    for(a in admins.vals()){ if(a == Principal.fromText(p)){ return true}};
    var tempBuffer = Buffer.fromArray<Principal>(admins);
    tempBuffer.add(Principal.fromText(p));

    admins := Buffer.toArray<Principal>(tempBuffer);
    true;
  };

  public shared ({caller}) func signUp(name: Text, sex: Text): async SignUpResult{
    //TODO: Validación de campos
    if(Principal.isAnonymous(caller)){ return #err(#CallerAnnonymous)};
    if(inBlackList(caller)){ return #err(#InBlackList)};
    switch(userIds.get(caller)){
      case null{
        let timestamp = Time.now() / 1_000_000_000: Int; //Timestamp in seconds
        userIds.put(caller,currentUserId);
        
        let newMember = {
          name;
          country = null;
          admissionDate = timestamp; 
          sex = ?sex;
          avatar = null;
          birthdate = null; //DDMMAAAA
          votedPosts = [];
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
  public shared ({caller}) func getMiId(): async ?Nat { userIds.get(caller) };
  public shared ({caller}) func getMiUser(): async ?User { 
    switch(userIds.get(caller)){
      case null {return null};
      case (?userId){
        return users.get(userId);
      }
    } 
  };

  public shared ({caller}) func userConfig(settings: UserSettings): async (){
    
    switch(getUser(caller)){
      case null {};
      case (?user){
        var userId = 0;
        switch (userIds.get(caller)){
          case null { return };
          case (?id) {userId := id};
        };
        let updateUser = {
          name = switch (settings.name){
            case null{user.name};
            case (?newName) {newName};
          };
          avatar = switch (settings.avatar) {
            case null { user.avatar};
            case (newAvatar) {newAvatar}
          };
          country = switch (settings.country) {
            case null { user.country};
            case (newCountry) {newCountry};
          };
          sex = switch(settings.sex){
            case null {null};
            case (newSex) {newSex};
          };
          birthdate = user.birthdate;
          admissionDate = user.admissionDate;
          votedPosts = user.votedPosts;
        };
        users.put(userId,updateUser)
      };
    };
  };

  public shared ({caller}) func loadAvatar(avatar: Blob):async ?Blob{
    switch(userIds.get(caller)){
      case null{return null};
      case (?userId){
        switch (users.get(userId)){
          case null{ return null};
          case (?user){   
            //comprimir la imagen     
            var userUpdate = {
              name = user.name;
              country = user.country;
              birthdate = user.birthdate; //DDMMAAA
              admissionDate = user.admissionDate; //Timestamp in secconds 
              //account = user.account;
              avatar = ?avatar;
              sex = user.sex;
              votedPosts = user.votedPosts;
            };
            users.put(userId,userUpdate);
            return userUpdate.avatar;
          };
        };
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
          score = null;
        };
        incomingPublications.put(currentTutorialId, pub);
        currentTutorialId += 1;
        #ok(pub);
      };
    };
  };

  func getUser(p: Principal): ?User{
    switch(userIds.get(p)){
      case null{null};
      case(?userId){users.get(userId)};
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
    return Iter.toArray(incomingPublications.vals());
  };

  public query func getAprovedPublication(): async [(TutoId, Publication)]{  
    return Iter.toArray(aprovedPublications.entries());
  };
  
  public query func getPubFromUser(userId: Nat): async [Publication]{
    var pubs = Iter.toArray(aprovedPublications.vals());
    Array.filter<Publication>(pubs, func x: Bool {x.autor == userId});  
  };

  public query func getPubByID(id: Nat): async ?Publication{
    aprovedPublications.get(id);
  };
  
  public query func search(target : Text) : async [Publication] {
    var tokens = Iter.fromArray<Text>([]);
    let pubs = aprovedPublications.vals();
    let tempBuffer = Buffer.fromArray<Publication>([]);
    label for0 loop {
      switch (pubs.next()) {
        case (?pub) {
          tokens := Text.split(target, #char(' '));
          label for1 loop {
            switch (tokens.next()) {
              case (?p) {
                if (Text.contains(pub.content.title, #text(p))) {
                  tempBuffer.add(pub);
                  break for1;
                };
              };
              case (null) break for1;
            };
          };
        
        };
        case null { break for0 };
      };
    };
    Buffer.toArray<Publication>(tempBuffer);
  };

/*
  func inArray<T>(a: [T], e: T): Bool{
    for(elem in a.vals()){
      if(elem == e){return true};
    };
    return false;
  };

  public shared ({caller}) func qualify(id: TutoId, q: Nat): async Bool{
    switch(getUser(caller)){
      case null {return false };
      case(?user){
        if(inArray<TutoId>(user.votedPosts, id)){
          return false;
        };

      };
    };
  };
  */

};
