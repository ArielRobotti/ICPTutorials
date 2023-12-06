

module{
    public type UserSettings = {
        name: ?Text;
        avatar: ?Blob;
        country: ?Text;
        sex: ?Sex;
    };
    public type User = {
        name: Text;
        avatar: ?Blob;
        birthdate: ?Nat; //DDMMAAA
        admissionDate: Int; //Timestamp in secconds
        country: ?Text;
        //account: Account;
        sex: ?Sex;
    };

    public type Sex = {
        #Male;
        #Female;
        #NonBinary;   
    };
    public type SignUpErrors = {
        #CallerAnnonymous;
        #IsAlreadyAMember;
        #InBlackList;
    };
}