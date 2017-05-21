#include <IRremote.h>
#include <IRremoteInt.h>

int RECV_PIN = A0;

IRrecv irrecv(RECV_PIN);

decode_results results;

void setup() {         
  Serial.begin(9600);
  irrecv.enableIRIn();    
}

void loop(){
  
  if (irrecv.decode(&results)) {
    if (results.value == 16716015){
      Serial.write(0);
    }else if (results.value == 16726215){
      Serial.write(1);
    }else if (results.value == 16734885){
      Serial.write(2);
    }else if (results.value == 16738455){
      Serial.write(3);
    }
    irrecv.resume();
  }
  delay(20);
}
