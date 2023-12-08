

module{
    public type UserSettings = {
        name: ?Text;
        avatar: ?Blob;
        country: ?Text;
        sex: ?Text;
    };
    public type User = {
        name: Text;
        avatar: ?Blob;
        birthdate: ?Nat; //DDMMAAA
        admissionDate: Int; //Timestamp in secconds
        country: ?Text;
        //account: Account;
        sex: ?Text;
        votedPosts: [Nat];
    };

    public type SignUpErrors = {
        #CallerAnnonymous;
        #IsAlreadyAMember;
        #InBlackList;
    };
}