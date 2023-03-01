int analogPin = A3; // define analog pin
int digitalPin = 7; // define digital pin
int analogRefPin = A2; // define analogRef pin

int analogValue = 0;  // initial analog value
int analogRefValue = 0; // initial analogRef value
int digitalValue = 0;// initial digital value
int digitalRefValue = 0;// initial digitalRef value

void setup() {
   pinMode(digitalPin, INPUT); // set digital pin as INPUT
   Serial.begin(9600);
}
void loop() {
                        
  analogValue = analogRead(analogPin); 
  analogRefValue = analogRead(analogRefPin); 
  digitalValue = digitalRead(digitalPin); 
     
  String analogString = String(analogValue);
  String analogRefString = String(analogValue);
  String digitalString = String(digitalValue);

  String finalValue = String(analogString + "," + digitalString + ","+analogRefValue );
    
  Serial.println(finalValue);          
  delay(100);

}