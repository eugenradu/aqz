# Schema activităților

```mermaid
flowchart TD

%% ============ INIȚIERE REFERAT ============

start([Start proces achiziție])
start --> redactareReferat

redactareReferat[Redactare referat de necesitate - draft]
redactareReferat --> definireLoturiReferat
definireLoturiReferat[Definire loturi interne - LotReferat]
definireLoturiReferat --> asociereProduseComercialeCunoscute
asociereProduseComercialeCunoscute[Asociere produse comerciale cunoscute la produse generice]
asociereProduseComercialeCunoscute --> validareReferat
validareReferat[Validare internă referat]
validareReferat --> trimiteSpreAprobare

trimiteSpreAprobare[Aprobare formală referat]
trimiteSpreAprobare -->|Aprobat| atribuireReferatID
trimiteSpreAprobare -->|Respins| redactareReferat

atribuireReferatID[Referat aprobat: devine disponibil pentru achiziții]

%% ============ OFERTARE ============

atribuireReferatID --> alegereTipProcedura
alegereTipProcedura[Serviciu achiziții decide tipul procedurii]
alegereTipProcedura --> creareProcedura

creareProcedura[Creare procedură achiziție]
creareProcedura --> definireLoturiProcedura

definireLoturiProcedura[Definire loturi procedură - LotProcedura - pot agrega produse din mai multe referate și/sau loturi interne]
definireLoturiProcedura --> publicareProcedura

publicareProcedura[Publicare procedură / inițiere ofertare]
publicareProcedura --> receptionareOferte

receptionareOferte[Înregistrare oferte comerciale de la furnizori]
receptionareOferte --> inregistrareProduseComercialeNoi
inregistrareProduseComercialeNoi[Înregistrare produse comerciale noi din ofertă]
inregistrareProduseComercialeNoi --> validareConversiiUM
validareConversiiUM[Validare echivalență între UM comercială și UM cerută]
validareConversiiUM --> evaluareOferte

evaluareOferte[Evaluare oferte per lot]
evaluareOferte --> selectieCastigator

selectieCastigator[Selectare ofertă câștigătoare pe lot]
selectieCastigator --> semnareContract

%% ============ CONTRACTARE ȘI COMENZI ============

semnareContract[Semnare contract - acord-cadru sau contract ferm]
semnareContract --> verificareTipContract

verificareTipContract{Contract ferm?}
verificareTipContract -- Da --> creareComandaAutomata
verificareTipContract -- Nu --> creareComandaSubsecventa

creareComandaAutomata[Creare automată comandă din contract]
creareComandaSubsecventa[Creare comandă subsecventă în baza acordului-cadru]

creareComandaAutomata --> emitereComanda
creareComandaSubsecventa --> emitereComanda

emitereComanda[Emitere comandă + transmitere furnizor]

%% ============ LIVRARE ============

emitereComanda --> receptionareLivrare

receptionareLivrare[Recepție produse: factură, aviz, cantitate convertită în UM de lucru]
receptionareLivrare --> inregistrareLivrare

inregistrareLivrare[Înregistrare livrare în sistem]
inregistrareLivrare --> verificareLivrareCompleta

verificareLivrareCompleta{Comanda livrată complet?}
verificareLivrareCompleta -- Nu --> asteptareEtapaUrmatoare
verificareLivrareCompleta -- Da --> finalizareComanda

asteptareEtapaUrmatoare[Se așteaptă livrare suplimentară]
asteptareEtapaUrmatoare --> receptionareLivrare

finalizareComanda[Marcarea comenzii ca „livrată”]
finalizareComanda --> creareIntrareStoc

%% ============ INTEGRARE CU STOCURI ============

creareIntrareStoc[Creare intrare în modulul de gestiune stocuri - în viitor]
creareIntrareStoc --> stop

stop([Sfârșit proces achiziție])
```
