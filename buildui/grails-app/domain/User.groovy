class User {
    String email
    String password
    public String toString() { 
        return email;
    }
    static constraints = {
        email(email:true)
        email(unique:true)
        password(blank:false, password:true)
    }
}
