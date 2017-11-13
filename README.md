# Garble

`garble` is a set of tools that aims to make data masking simpler and more secure.

 + **Simplicity**: `garble` is designed to be used inline with select queries -- no external tools required.
 + **Security**: by masking the data before it leaves the database, `garble` prevents the real data from "leaking" onto test servers, temp files, or anywhere else it shouldn't.
 + **Repeatablility**: `garble` functions are deterministic, which allows for simpler updates to the test data bed as the real data evolves.

## How to install

 + For your target platform, run the `setup.sql` script as an administrator. This will set up a `garble` schema, as well as the core masking logic used by all garble functions.
 + Once the garble core is installed, you can run the `*_functions.sql` scripts to create the functions to mask certain types of data. (Some functions -- like names -- require the scripts in the `data/` folder to be run first)

`garble` currently supports MySQL, with plans to add more platforms. If you'd like your favorite RDBMS to be next, put in a feature request!

## How to use

### Names:
```
select garble.gb_name("Michael") => SAMARA
select garble.gb_name_by_gender("Michael", "M") => EMERSON
```

### Dates:
```
select garble.gb_date_by_tol("1992-01-06",5) => 1993-06-20
```
