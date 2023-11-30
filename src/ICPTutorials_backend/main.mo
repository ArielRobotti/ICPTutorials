import Principal "mo:base/Principal";
import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
import Types "Types";
import Member "member";
import Account "account";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Hash "mo:base/Hash";


actor ICPTutorials = {

  let DAO = Principal.fromText("aaa.aaaa");
  public type Tutorial = Types.Tutorial;
  public type Publication = Types.Publication;
  public type Account  = Account.Account;
  public type User = Member.Member;
  public type SignUpResult = Result.Result<User,Member.SignUpErrors>;
  public type PublishResult = Result.Result<Publication, Text>;
  public type TutoId = Nat;

  //stable var incomingTutorials: [Tutorial] = [];
  stable var userId = 0;
  stable var tutorialId = 0;
  let ledger = HashMap.HashMap<Account, Nat>(1, Account.accountsEqual, Account.accountsHash);
  let users = HashMap.HashMap<Principal,User>(1, Principal.equal, Principal.hash);
  let blackList = HashMap.HashMap<Principal,()>(0, Principal.equal, Principal.hash);
  
  var incomingPublications = HashMap.HashMap<TutoId,Publication>(1, Types.tutoIdEqual, Types.tutoIdHash);
  var aprovedPublications = HashMap.HashMap<TutoId,Publication>(1, Types.tutoIdEqual, Types.tutoIdHash);

  func inBlackList(p: Principal): Bool{
    return switch(blackList.get(p)){
      case null{false};
      case _{true};
    };
  };

  public shared ({caller}) func signUp(name: Text, birthdate: ?Nat, sex: ?Member.Sex): async SignUpResult{
    //TODO: Validación de campos
    if(Principal.isAnonymous(caller)){ return #err(#CallerAnnonymous)};
    if(inBlackList(caller)){ return #err(#InBlackList)};
    switch(users.get(caller)){
      case null{
        let timestamp = Time.now() / 1_000_000_000: Int; //Timestamp in seconds
        let newMember = {
          id = userId;
          name;
          birthdate; //DDMMAAAA
          admissionDate = timestamp; 
          sex;
        };
        userId += 1;
        users.put(caller,newMember);
        return #ok(newMember);
      };
      case (?member){
        return #err(#IsAlreadyAMember);
      };
    };    
  };

  func isMember(p: Principal): Bool{
    return switch (users.get(p)){
      case null{false};
      case _{true};
    };
  };
  public shared ({caller}) func publish(content: Tutorial): async PublishResult{
    if(not isMember(caller)){ return #err("Caller is not a member")};
    let date = Time.now() / 1_000_000_000: Int;
    let pub = {
      autorPrincipal = caller;
      date;
      content;
    };
    incomingPublications.put(tutorialId, pub);
    tutorialId += 1;
    #ok(pub);
  };

  public shared ({caller}) func aprovePublication(id: Nat):async Result.Result<(), Text> {
    assert (caller != DAO);
    switch (incomingPublications.remove(id)){
      case null{return #err("Tutorial id does not exist")};
      case (?tuto){
        aprovedPublications.put(id, tuto);
        return #ok();
      };
    };    
  };

  public shared ({caller}) func rejectPublication(id: Nat):async Result.Result<(), Text> {
    assert (caller != DAO);
    return switch (incomingPublications.remove(id)){
      case null{#err("Tutorial id does not exist")};
      case (_){#ok()};
    };    
  }; 

  public shared func getAprovedPublication(): async [Publication]{
    return Iter.toArray(aprovedPublications.vals());
  };
  
  public shared ({caller}) func getIncomingPublication(): async [Publication]{
    assert (caller != DAO);
    return Iter.toArray(aprovedPublications.vals());
  };


};
