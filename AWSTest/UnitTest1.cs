using AWSCOnsole;

namespace AWSTest
{
    [TestClass]
    public class UnitTest1
    {
        Hello hello=new Hello();    
        [TestMethod]
        public void TestMethod1()
        {
       
            var expected = "Hello World";
            var actual = hello.GetName();
            
            Assert.AreEqual(expected, actual);  
        }
    }
}