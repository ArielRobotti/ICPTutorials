import Types "Types";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";


shared ({caller}) actor class Dao(name: Text, manifesto: Text, founders: [(Principal, Types.Member)]) = {
    type Member = Types.Member;
    type addMemberResult = Result.Result<(),Text>;

    public func getName(): async Text {name};
    public func getManifesto(): async Text {manifesto};

    let members = HashMap.HashMap<Principal,Types.Member>(founders.size(),Principal.equal,Principal.hash);
    for(m in founders.vals()){ 
        members.put(m.0, m.1)
    };

    public query func isAMember(p: Principal): async Bool{
        switch(members.get(p)){
            case null {
                return false;
            };
            case (?member){
                return true;
            };
        };
    };

    public shared({caller}) func addMember(m: Member): async addMemberResult{
        if(await isAMember(caller)){
            return #err("Is member")
        };
        members.put(caller, m);
        #ok();
    };

    func removeMember(m: Principal): Result.Result<Member,Text>{   
        switch(members.remove(m)){
            case null{
                return #err("Is not a member")
            };
            case (?member){
                return #ok(member)
            };
        };
    };
    
}