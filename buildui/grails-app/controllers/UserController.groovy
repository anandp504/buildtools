import org.apache.commons.codec.digest.DigestUtils
import com.tumri.LoginAuth.LDAPLoginModule;

class UserController {

    def login = {
        if (session.user) {
            redirect(controller:'component',action:'list')
        }
    }

    def logout = {
        session.removeAttribute('email');
        redirect(action:'login')
    }

    def create = {
    }

    def save = {
        def user = new User(params)

        if ((params['rpassword'] == null) ||
            (!params['rpassword'].equals(params['password']))) {
            flash.message = "Passwords do not match. Please try again."
            render(view:'create', model:['user':user])
            return;
        }
        if (!user.hasErrors()) {
            user.password = DigestUtils.md5Hex(user.password);
            if (user.save()) {
                session.user = user
                flash.message = "User ${user.email} has been created and logged in."
                redirect(controller:'component',action:'list')
            }
            else {
                flash.message = "User ${user.email} could not be saved."
                render(view:'create', model:['user':user])
                return;
            }
        }
        else {
            render(view:'create', model:['user':user])
        }
    }

    def doLogin = {

        //def user = User.findWhere(email:params['email'], password:DigestUtils.md5Hex(params['password']))
	LDAPLoginModule login = new LDAPLoginModule();
	String email = null;
	email = login.authenticateUserInLDAP(request.getParameter('username'),request.getParameter('password'));

        //def user = User.findWhere(email:params['email']);
        if (email != null) { //login success
            session.email = email;
            println "User logged in is "+session.email;
            //session.user.putAt(email,(String)email);
            redirect(controller:'component',action:'list')            
        }
        else {
            flash.message = "Invalid login/password, Please try with LDAP credentials";
            redirect(action:'login')
        }
    }
}
