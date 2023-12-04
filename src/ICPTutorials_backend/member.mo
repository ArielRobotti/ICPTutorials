

module{
    public type Member = {
        name: Text;
        birthdate: ?Nat; //DDMMAAA
        admissionDate: Int; //Timestamp in secconds 
        //account: Account;
        avatar: ?Blob;
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