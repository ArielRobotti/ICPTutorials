module{

    public type Member = {
        name: Text;
        birthdate: Nat; //DDMMAAA
        //account: Account;
        sex: Sex;
    };

    public type Sex = {
        #Male;
        #Female;
        #NonBinary;   
    };

    public type Mode = {
        #Add;
        #Remove;
    };

    public type Tutorial = {
        title: Text;  //Limitar a 100 caracteres
        autorPrincipal: Principal;
        date: Int; //Timestamp
        tags: [Text];
        html: Text; //Se genera automaticamente desde el front
        assets: [Blob];
        //La hoja de estilos es comun para todos los tutoriales    
    };


}