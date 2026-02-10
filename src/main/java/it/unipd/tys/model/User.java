package it.unipd.tys.model;

import java.time.LocalDate;

public class User {
    private final int id;
    private final String firstName;
    private final String lastName;
    private final LocalDate birthDate;
    private final String degreeLevel;
    private final String major;
    private final String department;
    private final String university;
    private final String email;
    private final String passwordHash;

    public User(int id, String firstName, String lastName, LocalDate birthDate,
                String degreeLevel, String major, String department, String university,
                String email, String passwordHash) {
        this.id = id;
        this.firstName = firstName;
        this.lastName = lastName;
        this.birthDate = birthDate;
        this.degreeLevel = degreeLevel;
        this.major = major;
        this.department = department;
        this.university = university;
        this.email = email;
        this.passwordHash = passwordHash;
    }

    public int getId() { return id; }
    public String getFirstName() { return firstName; }
    public String getLastName() { return lastName; }
    public LocalDate getBirthDate() { return birthDate; }
    public String getDegreeLevel() { return degreeLevel; }
    public String getMajor() { return major; }
    public String getDepartment() { return department; }
    public String getUniversity() { return university; }
    public String getEmail() { return email; }
    public String getPasswordHash() { return passwordHash; }
}
