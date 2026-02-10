package it.unipd.tys.model;

public class User {
    private final int id;
    private final String email;
    private final String passwordHash;

    public User(int id, String email, String passwordHash) {
        this.id = id;
        this.email = email;
        this.passwordHash = passwordHash;
    }

    public int getId() { return id; }
    public String getEmail() { return email; }
    public String getPasswordHash() { return passwordHash; }
}
