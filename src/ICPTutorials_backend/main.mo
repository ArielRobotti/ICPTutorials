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

actor ICPTutorials = {

  let DAO = Principal.fromText("aaa.aaaa");
  public type Tutorial = Types.Tutorial;
  public type Publication = Types.Publication;
  public type Account  = Account.Account;
  public type Member = Member.Member;
  public type SignUpResult = Result.Result<Member,Text>;
  public type PublishResult = Result.Result<Publication, Text>;

  //stable var incomingTutorials: [Tutorial] = [];
  stable var memberId = 0;
  stable var tutorialId = 0;
  let ledger = HashMap.HashMap<Account, Nat>(1, Account.accountsEqual, Account.accountsHash);
  let members = HashMap.HashMap<Principal,Member>(1, Principal.equal, Principal.hash);
  var incomingTutorials = HashMap.HashMap<Nat,Publication>(1, Nat.equal, Types.hashNat);
  var aprovedTutorials = HashMap.HashMap<Nat,Publication>(1, Nat.equal, Types.hashNat);

  public shared ({caller}) func signUp(name: Text, birthdate: ?Nat, sex: ?Member.Sex): async SignUpResult{
    //TODO: Validación de campos 
    switch(members.get(caller)){
      case null{
        let timestamp = Time.now() / 1_000_000_000: Int; //Timestamp in seconds
        let newMember = {
          id = memberId;
          name;
          birthdate; //DDMMAAAA
          admissionDate = timestamp; 
          sex;
        };
        memberId += 1;
        members.put(caller,newMember);
        return #ok(newMember);
      };
      case (?member){
        return #err("Caller is already a member");
      };
    };    
  };

  func isMember(p: Principal): Bool{
    return switch (members.get(p)){
      case null{false};
      case _{true};
    };
  };
  public shared ({caller}) func publish(content: Tutorial): async PublishResult{
    if(not isMember(caller)){ return #err("Caller is not member")};
    let date = Time.now() / 1_000_000_000: Int;
    let pub = {
      autorPrincipal = caller;
      date;
      content;
    };
    incomingTutorials.put(tutorialId, pub);
    tutorialId += 1;
    #ok(pub);
  };

  public shared ({caller}) func aprovePublication(id: Nat):async Result.Result<(), Text> {
    if(caller != DAO) {return #err("Caller is not authorized")};
    switch (incomingTutorials.remove(id)){
      case null{return #err("Tutorial id does not exist")};
      case (?tuto){
        aprovedTutorials.put(id, tuto);
        return #ok();
      };
    };    
  };

  public shared ({caller}) func getAprovedPublish(): async [Publication]{
    return Iter.toArray(aprovedTutorials.vals());
  };



  

};
