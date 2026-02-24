# Hotel Management Database

## Descriere
Bază de date relațională pentru gestionarea activității unui hotel.  
Sistemul administrează informații despre clienți, camere, rezervări, servicii, plăți și angajați.

Proiectul urmărește automatizarea proceselor de rezervare și monitorizarea operațiunilor hoteliere.

## Structură

Baza de date conține 8 tabele:

- CLIENTI
- TIPURI_CAMERA
- CAMERE
- ANGAJATI
- SERVICII
- REZERVARI
- REZERVARI_SERVICII (tabel intermediar)
- PLATI

## Relații

- ONE-TO-MANY:  
  - TIPURI_CAMERA → CAMERE  
  - CLIENTI → REZERVARI  

- MANY-TO-MANY:  
  - REZERVARI ↔ SERVICII (implementată prin REZERVARI_SERVICII)
    
## Constrângeri implementate

- PRIMARY KEY  
- FOREIGN KEY  
- NOT NULL  
- UNIQUE  
- CHECK
  
## Tehnologii

- SQL  
- Oracle SQL Developer  

## Concepte demonstrate

- Modelare relațională  
- Normalizare  
- Interogări diversificate și complexe
- Integritate referențială

## Schemă conceptuală

![Schema ERD](docs/schema.png)
