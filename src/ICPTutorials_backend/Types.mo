module{
    public type Member = {
        name: Text;
        birthdate: Nat; //DDMMAAA
        sex: Sex;
    };

    public type Sex = {
        #Male;
        #Female;
        #NonBinary;   
    };
}