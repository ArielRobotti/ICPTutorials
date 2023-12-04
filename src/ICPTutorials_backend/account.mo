import Option "mo:base/Option";
import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Hash "mo:base/Hash";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
module{
    
    public type SubAccount = Blob;
    public type Account = {
        owner: Principal;
        subAccount: ?SubAccount;
    };

    public func defaultAccount(): SubAccount {
        Blob.fromArrayMut(Array.init(32, 0: Nat8));
    };

    public func accountsEqual(a: Account, b: Account): Bool{
        if(a.owner != b.owner) { return false };
        let subAccountA = Option.get<SubAccount>(a.subAccount, defaultAccount());
        let subAccountB = Option.get<SubAccount>(b.subAccount, defaultAccount());
        subAccountA == subAccountB;
    };

    public func accountsHash(a: Account): Nat32 {
        let subAccount = Option.get<SubAccount>(a.subAccount, defaultAccount());
        Principal.hash(a.owner)/2 + Blob.hash(subAccount)/2;
    };

    public func accountBelongsToPrincipal(account: Account, owner: Principal): Bool{
        account.owner == owner;
    };

    public func sameOwner(accounts: [Account]): Bool {
        let owner = accounts[0].owner;
        for(i in Iter.range(1, accounts.size() -1)){
            if(accounts[i].owner == owner){ return false};
        };
        true;       
    };
    public func getAccountsFromPrincipal(ledger: [Account],p: Principal): [Account]{
        let tempBuffer = Buffer.fromArray<Account>([]);
        for(i in ledger.vals()){
            if(i.owner == p){tempBuffer.add(i)};
        };
        Buffer.toArray<Account>(tempBuffer);
    }
};