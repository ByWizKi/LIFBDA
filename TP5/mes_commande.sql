-- Statistique de la base de donné
analyse optimisation.clients, optimisation.commandes, optimisation.produits, optimisation.concerne,optimisation.livraisons;

-- Pour chaque question suivante, rédigez une requête SQL qui répond à la question, et demandez à Postgresql une analyse de la requête de la façon suivante : EXPLAIN (analyse,buffers) select ... from...etc...

-- Requete Listez toutes les informations sur les produits.
select * from produits;

-- Requete Listez le numéro et le nom de tous les produits.
select nump, nomp from produits;

-- Idem, en ajoutant la clause "distinct".
select distinct nump, nomp from produits;

-- Même question en ordonnant le résultat selon le nom des produits.
select nump, nomp from produits order by nomp ASC;

-- Listez les produits dont le nom est 'nomp_327'.
select nump from produits where nomp='nomp_327';

-- Donnez le nombre de commandes par client (numc, nombre).
select numc, count(*) from concerne group by numc order by numc ASC;

-- Donnez les infos sur chaque commande, sous la forme ('nom du client', 'date de la commande').
select nomc, datecom from commandes join clients using (numc);

-- On souhaite afficher les produits commandés par les clients.
select nomp from produits join concerne using (nump);



-- Création d'un index sur NumP
    begin;
    CREATE INDEX index_nump ON produits USING HASH (nump);

    explain (analyse, buffers) select numc, count(*) from concerne group by numc order by numc ASC;

    rollback;