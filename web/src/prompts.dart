import 'dart:html';

void showGetReady() {
  hideGameOver();
  querySelector("#getReady").style.visibility = "visible";
}

void hideGetReady() {
  querySelector("#getReady").style.visibility = "hidden";
}

void showGameOver() {
  hideGetReady();
  querySelector("#gameOver").style.visibility = "visible";
}

void hideGameOver() {
  querySelector("#gameOver").style.visibility = "hidden";
}