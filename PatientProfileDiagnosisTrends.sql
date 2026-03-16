SELECT * 
FROM patient_visits.patient_visits;

#Creating Age Bracket

##### Tableau Table 'Age Brackets with male, female, and total count' #####

WITH age_brackets
	AS (SELECT *, CASE
	WHEN patient_age BETWEEN 0 AND 17 THEN '0-17'
    WHEN patient_age BETWEEN 18 AND 39 THEN '18-39'
    WHEN patient_age BETWEEN 40 AND 64 THEN '40-64'
    ELSE '65+'
    END AS AgeBrackets
	FROM patient_visits.patient_visits
	)
SELECT ab.AgeBrackets
		,pf.Female_count
        ,pm.Male_count
#        ,ac.Total_counts
FROM age_brackets AS ab
JOIN 
	(SELECT AgeBrackets, COUNT(AgeBrackets) AS Total_counts
	FROM age_brackets
	GROUP BY AgeBrackets
    ) AS ac
ON ab.AgeBrackets = ac.AgeBrackets
JOIN 
(SELECT AgeBrackets, COUNT(patient_sex) AS Male_count
	FROM age_brackets
	WHERE patient_sex = 'male'
	GROUP BY AgeBrackets
	) AS pm
ON ab.AgeBrackets = pm.AgeBrackets
JOIN
(SELECT AgeBrackets, COUNT(AgeBrackets) AS Female_Count
    FROM age_brackets
	WHERE patient_sex = 'female'
    GROUP BY AgeBrackets
    ) AS pf
ON ab.AgeBrackets = pf.AgeBrackets
GROUP BY AgeBrackets
;

##### TABLEAU TABLE ICD sex count #####

SELECT pm.icd_code, male_count, female_count
FROM 
	(SELECT p1.icd_code, p1.patient_sex, COUNT(p1.icd_code) AS male_count
	FROM patient_visits.patient_visits p1
	WHERE p1.patient_sex = 'Male'
	GROUP BY p1.icd_code
	) AS pm
JOIN
	(SELECT p2.icd_code, p2.patient_sex, COUNT(p2.icd_code) AS female_count
	FROM patient_visits.patient_visits p2
	WHERE p2.patient_sex = 'Female'
	GROUP BY p2.icd_code
	) AS pf
ON pm.icd_code = pf.icd_code
ORDER BY 1
;

##### Tableau Table ICD code count #####

SELECT icd_code, COUNT(icd_code) AS ICD_Count
FROM patient_visits.patient_visits
GROUP BY icd_code
ORDER BY 2 DESC
LIMIT 10
;

##### Tablaeu Table ICD code count by sex #####

SELECT ic.icd_code
		,fc.female_count
        ,mc.male_count
#        ,total_count
FROM patient_visits.patient_visits AS ic
JOIN
	(SELECT icd_code, COUNT(icd_code) AS total_count
	FROM patient_visits.patient_visits
    GROUP BY icd_code
    ) AS tc
ON ic.icd_code = tc.icd_code
LEFT JOIN
	(SELECT icd_code, COALESCE(COUNT(patient_sex)) AS female_count
    FROM patient_visits.patient_visits
    WHERE patient_sex = 'female'
    GROUP BY icd_code
    ) AS fc
ON ic.icd_code = fc.icd_code
LEFT JOIN
	(SELECT icd_code, COUNT(patient_sex) AS male_count
	FROM patient_visits.patient_visits
    WHERE patient_sex = 'male'
    GROUP BY icd_code
    ) AS mc
ON ic.icd_code = mc.icd_code
GROUP BY icd_code, female_count, male_count
ORDER BY 1
;

##### ICD code count by age bracket #####

WITH age_brackets
	AS (SELECT *, CASE
	WHEN patient_age BETWEEN 0 AND 17 THEN '0-17'
    WHEN patient_age BETWEEN 18 AND 39 THEN '18-39'
    WHEN patient_age BETWEEN 40 AND 64 THEN '40-64'
    ELSE '65+'
    END AS AgeBrackets
FROM patient_visits.patient_visits
)
SELECT icd_code, 
		AgeBrackets, 
		COUNT(AgeBrackets) AS AgeBracketCount
FROM age_brackets
GROUP BY AgeBrackets, icd_code
ORDER BY 3 DESC;


###### Tableau Table Visit Counts High Utilizers ######

SELECT  CONCAT(patient_id,(substring_index(date_of_birth, '/',-1))) AS patientID #Creating Unique Client ID due to ambiguity
#		,patient_sex
#        ,patient_age
		,COUNT(patient_id) AS visit_count
FROM patient_visits.patient_visits
GROUP BY patient_id
#		,date_of_birth
#        ,patient_sex
#        ,patient_age
		,patientID
ORDER BY 1 #COUNT(patient_id) DESC
;

##### KPIs #####

WITH PCount AS
(
SELECT  CONCAT(patient_id,(substring_index(date_of_birth, '/',-1))) AS patientID
#		,patient_sex
#        ,patient_age
		,COUNT(patient_id) AS visit_count
FROM patient_visits.patient_visits
GROUP BY #patient_id
#		,date_of_birth
#        ,patient_sex
#        ,patient_age
		patientID
ORDER BY COUNT(patient_id) DESC
)
SELECT CONCAT(ROUND(AVG(visit_count),2),'%') AS Average_Visit #Creating Unique Client ID due to ambiguity
		,SUM(visit_count) AS total_visits
        ,COUNT(patientID) AS total_patients
FROM PCount
;

##############################################