import org.apache.commons.codec.digest.DigestUtils

class BootStrap {

     def init = { servletContext ->
        def user = User.findByEmail('vijaya@tumri.com');
        if (!user) 
            new User(email:'vijaya@tumri.com', password:DigestUtils.md5Hex('vijay123')).save()
        user = User.findByEmail('epoon@tumri.com');
        if (!user) 
            new User(email:'epoon@tumri.com', password:DigestUtils.md5Hex('esther123')).save()
        user = User.findByEmail('snawathe@tumri.com');
        if (!user) 
            new User(email:'snawathe@tumri.com', password:DigestUtils.md5Hex('sandeep123')).save()
        user = User.findByEmail('sundark@tumri.com');
        if (!user) 
            new User(email:'sundark@tumri.com', password:DigestUtils.md5Hex('sundar123')).save()
     }
     def destroy = {
     }
} 
