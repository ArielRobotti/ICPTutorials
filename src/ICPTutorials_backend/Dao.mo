import Types "Types";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";



shared ({caller}) actor class Dao(name: Text, manifesto: Text, founders: [(Principal, Types.Member)]) = {
    type Member = Types.Member;
    type Mode = Types.Mode;
    type updateMembersResult = Result.Result<(?Member),Text>;

    public func getName(): async Text {name};
    public func getManifesto(): async Text {manifesto};

    let members = HashMap.HashMap<Principal,Types.Member>(founders.size(),Principal.equal,Principal.hash);
    for(m in founders.vals()){ 
        members.put(m.0, m.1)
    };

    public func isAMember(p: Principal): async Bool{_isAMember(p)};

    func _isAMember(p: Principal): Bool{
        return switch(members.get(p)){
            case null { false};
            case (_) { true};
        };
    };
    

    public shared ({caller}) func updateMembers(p: ?Principal, mode: Mode, member: ?Member): async updateMembersResult{
        if(not _isAMember(caller)){return #err("Caller is not a member")};

        switch(mode){
            case (#Add){
                switch (member){
                    case null{
                        return #err("Member data require")
                    };   
                    case (?m){
                        switch p {
                            case null{return #err("Principal require")};
                            case (?p){return addMember(p, m)};
                        };
                    };
                };
            };
            case (#Remove){
                return removeMember(caller);
            };
        };
    };
    func addMember(p: Principal, m: Member): updateMembersResult{
        if(_isAMember(p)){
            return #err("Is a member")
        };
        members.put(caller, m);
        #ok(null);
    };

    func removeMember(m: Principal): updateMembersResult{
        switch(members.remove(m)){
            case null{
                return #err("Is not a member")
            };
            case (?member) {
                return #ok(?member)
            };
        };
    };
    
    
}