
function getPrologRequest(requestString, onSuccess, onError, port) {
    let requestPort = port || 8081;
    let request = new XMLHttpRequest();
    request.open('GET', 'http://localhost:' + requestPort + '/' + requestString, true);

    request.onload = onSuccess ;


    request.onerror = onError || prologRequestError;

    request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
    request.send();
}

function prologRequestError(data) {
    console.log('Prolog request error:');
    console.log(data);
}

function newGame(game){

	getPrologRequest('start',game);
}

function getCellsToMoveTo(board, player ,posX,posY,positions){
   // console.log('SERVER pede jogadas');
    let requestString = 'getCells('
    + JSON.stringify(board).replace(/"/g, '') + ','
    + JSON.stringify(player).replace(/"/g, '') + ','
    + posX + ','
    + posY + ')';

    getPrologRequest(requestString,positions);
}