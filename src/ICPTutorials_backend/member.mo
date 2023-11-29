

module{
    public type Member = {
        id: Nat;
        name: Text;
        birthdate: ?Nat; //DDMMAAA
        admissionDate: Int; //Timestamp in secconds 
        //account: Account;
        sex: ?Sex;
    };

    public type Sex = {
        #Male;
        #Female;
        #NonBinary;   
    };
}