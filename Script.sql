
-- En excluant les commandes annulées, quelles sont les commandes
-- récentes de moins de 3 mois que les clients ont reçues avec au moins 3
-- jours de retard ?


SELECT 
    order_purchase_timestamp, 
    order_delivered_customer_date, 
    order_estimated_delivery_date
FROM 
    orders
WHERE 
    order_status != 'canceled'
    AND order_purchase_timestamp >= date('now', '-3 months')
    AND order_delivered_customer_date > date(order_estimated_delivery_date, '+3 days');

/*
Notre requete ne routournera rien car la date la plus recente de commande est le 17/10/2018
*/

SELECT MAX(order_purchase_timestamp) AS most_recent_date
FROM orders;

/*
Qui sont les vendeurs ayant généré un chiffre d'affaires de plus de 100
000 Real sur des commandes livrés via Olist ?
*/

SELECT 
    oi.seller_id, 
    COUNT(oi.order_item_id) AS total_items_sold, 
    MIN(o.order_purchase_timestamp) AS first_order_date
FROM 
    order_items oi
JOIN 
    orders o ON oi.order_id = o.order_id
GROUP BY 
    oi.seller_id
HAVING 
    julianday('2018-10-17') - julianday(first_order_date) < 90
    AND total_items_sold > 30;


/*
Nouveaux vendeurs (moins de 3 mois d'ancienneté) ayant vendu plus de 30 produits
*/

-- Sélection des colonnes à afficher dans le résultat
SELECT 
    oi.seller_id,  -- Sélection de l'identifiant du vendeur
    COUNT(oi.order_item_id) AS total_items_sold,  -- Compte le nombre total de produits vendus par chaque vendeur
    MIN(o.order_purchase_timestamp) AS first_order_date  -- Trouve la date de la première commande pour chaque vendeur

-- Spécification de la ou des tables à partir desquelles les données seront extraites
FROM 
    order_items oi  -- Spécifie la table 'order_items' pour la jointure

-- Jointure avec une autre table pour obtenir des informations complémentaires
JOIN 
    orders o ON oi.order_id = o.order_id  -- Jointure avec la table 'orders' sur l'identifiant de commande

-- Groupe les données par vendeur
GROUP BY 
    oi.seller_id  -- Groupe les résultats par identifiant de vendeur

-- Filtrage des groupes de données
HAVING 
    julianday('2018-10-17') - julianday(first_order_date) < 90  -- Filtre pour les vendeurs dont la première commande est dans les 3 derniers mois
    AND total_items_sold > 30;  -- De plus, ces vendeurs doivent avoir vendu plus de 30 produits

/*
5 codes postaux avec plus de 30 commandes et le pire review score moyen sur les 12 derniers mois
*/

-- Sélection des colonnes à afficher dans le résultat
SELECT 
    c.customer_zip_code_prefix,  -- Sélection du code postal du client
    AVG(r.review_score) AS average_review_score,  -- Calcul de la moyenne des scores de critique pour chaque code postal
    COUNT(*) AS total_orders  -- Compte le nombre total de commandes pour chaque code postal

-- Spécification de la ou des tables à partir desquelles les données seront extraites
FROM 
    customers c  -- Spécifie la table 'customers' pour la jointure

-- Jointures avec d'autres tables pour obtenir des informations complémentaires
JOIN 
    orders o ON c.customer_id = o.customer_id  -- Jointure avec la table 'orders' sur l'identifiant du client
JOIN 
    order_reviews r ON o.order_id = r.order_id  -- Jointure avec la table 'order_reviews' sur l'identifiant de commande

-- Filtrage des données
WHERE 
    julianday('2018-10-17') - julianday(o.order_purchase_timestamp) <= 365  -- Filtre pour les commandes des 12 derniers mois

-- Groupe les données par code postal du client
GROUP BY 
    c.customer_zip_code_prefix  -- Groupe les résultats par code postal du client

-- Filtrage des groupes de données
HAVING 
    total_orders > 30  -- Filtre pour les codes postaux ayant plus de 30 commandes

-- Triage des résultats
ORDER BY 
    average_review_score ASC  -- Trie les résultats par score moyen de critique, du plus bas au plus élevé

-- Limite le nombre de résultats à afficher
LIMIT 5; 

