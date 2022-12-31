-- Add migration script here
INSERT INTO users (user_id, username, password_hash)
VALUES (
    'ddf8994f-d522-4659-8d02-c1d479057bE6',
    'admin',
    '$argon2id$v=19$m=15000,t=2,p=1$YX13a0pb8pY046g4JM4mjg$7l+IRe5p46WLqv65kdb45Frz1UhbKxezwKKjRJ1KfWo'
);

