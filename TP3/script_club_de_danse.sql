-- Script de création de la base du club de danse 


rollback;
drop schema if exists club_de_danse cascade;
create schema club_de_danse;
set search_path to club_de_danse;

--Entité professeur
create table professeurs(
	num_prof 		integer primary key,
	nom_prof		varchar(15),
	prenom_prof		varchar(15),
	tel_prof		varchar(13)
	);

-- Entité salariés spécialisation de professeurs (clé primaire et étrangère à la fois)
create table salaries(
	num_salarie 			integer primary key,
	dateembauche_salarie	date,
	echelon_salarie			integer,
	salaire_salarie			decimal,

	constraint fk_sal_prof foreign key (num_salarie) references professeurs(num_prof) on delete cascade on update cascade deferrable
	-- Si un professeur salarie est supprimé ou modifié dans professeurs, il est supprimé ou modifié dans salaries
);

-- Entité vacataires spécialisation de professeurs (clé primaire et étrangère à la fois)

create table vacataires(
	num_vacataire 				integer primary key,
	statut_vacataire			varchar(30), -- par exemple auto-entrepreneur, étudiant, sans-emploi...

	constraint fk_vac_prof foreign key (num_vacataire) references professeurs(num_prof) on delete cascade on update cascade deferrable
	-- Si un professeur vacataire est supprimé ou modifié dans professeurs, il est supprimé ou modifié dans vacataires

);

-- Entité Contrat, entité faible de Vacataire. L'identifiant local (pour un vacataire donné) est la date du contrat.
create table contrats(
	num_vacataire 		integer references vacataires(num_vacataire) on delete cascade on update cascade,
-- Si un vacataire est supprimé, tous ses contrats seront supprimés.
	date_contrat		date,
	nbheures_contrat	integer,
	
	primary key (num_vacataire,date_contrat)

);

-- La table des cours. Contient l'association (1-N) 'Est Responsable' sous la forme d'une clé étrangère vers
-- le professeur responsable. La participation de chaque cours ) cette association est obligatoire (NOT NULL).
create type niveau as enum('Débutant','Avancé','Expert');
create table cours(
	code_cours				integer primary key,
	intitule_cours			varchar(20),
	numresponsable_cours	integer not null references professeurs(num_prof) on update cascade,
-- ici, pas de 'on update delete' : si un professeur est supprimé, on ne supprime pas les cours dont il est responsable.
-- donc la suppression d'un professeur sera interdite s'il est responsable d'au moins un cours.
	niveau_cours			niveau
);


-- Table qui traduit l'association (N-N) 'Intervient' entre les professeurs et les cours.
create table prof_intervient_cours(
	num_prof		integer references professeurs(num_prof) on update cascade on delete cascade,
	code_cours		integer references cours(code_cours) on update cascade on delete cascade,
-- Si un prof est supprimé, ses interventions seront supprimées d'office.
-- Si un cours est supprimé, les interventions le concernant son supprimées d'office.

	primary key(num_prof,code_cours)
);

alter table club_de_danse.cours add constraint fk_cours_intervient foreign key (numresponsable_cours, code_cours) references club_de_danse.prof_intervient_cours (num_prof, code_cours) deferrable;

insert into club_de_danse.professeurs 
	(num_prof, 
	nom_prof, 
	prenom_prof, 
	tel_prof)

	values (1, 'Wiejacka', 'Jean', '0712121212');

begin;
	set constraints fk_cours_intervient deferred;

	insert into club_de_danse.cours 
	(code_cours, intitule_cours, numresponsable_cours, niveau_cours)
	values
	(1, 'Salsa', 1, 'Débutant');

	insert into club_de_danse.prof_intervient_cours
		(num_prof, code_cours)
		values
		(1, 1);
commit;

create function pas_dans_salaries (un_prof int) returns boolean
as $$
	begin
		perform
		from salaries
		where num_salarie = un_prof;

		return(found);
	end;
$$ language plpgsql;

create function pas_dans_vacataires (un_prof int) returns boolean
as $$
	begin
		perform
		from vacataires
		where num_vacataire = un_prof;

		return(found);
	end;
$$ language plpgsql;

alter table club_de_danse.vacataires add constraint not_in_S check (pas_dans_salaries(num_vacataire) = false);

alter table club_de_danse.salaries add constraint not_in_V check (pas_dans_salaries(num_salarie) = false);

insert into club_de_danse.vacataires (num_vacataire, statut_vacataire) values (1, 'En vacances');

alter table club_de_danse.professeurs add constraint in_S_or_V check(pas_dans_salaries(num_prof) = true or pas_dans_vacataires(num_prof) = true);

begin;
	set constraints fk_vac_prof deferred;

	insert into club_de_danse.vacataires
		(num_vacataire, statut_vacataire)
	values
		(2, 'En Vacance');

	insert into club_de_danse.professeurs 
		(num_prof, nom_prof, prenom_prof, tel_prof)
	values
		(2, 'toto', 'titi', '060606060');
commit;

create function est_dans_prof (un_prof int) returns boolean
as $$
	begin
		perform
		from professeurs
		where num_salarie = un_prof;
		return(found);
	end;
$$ language plpgsql;

create constraint trigger trigVac before delete on club_de_danse.vacataires derrable;

create trigger trigSal before delete on club_de_danse.salaries execute;