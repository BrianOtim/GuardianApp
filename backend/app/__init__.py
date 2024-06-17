from flask import Flask
from flask_mail import Mail
import os

mail = Mail()

def create_app():
    app = Flask(__name__)
    
    UPLOAD_FOLDER = 'uploads'
    app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

    # Ensure the upload folder exists
    if not os.path.exists(UPLOAD_FOLDER):
        os.makedirs(UPLOAD_FOLDER)
    
    #Configuration for Flask-Mail
    app.config['MAIL_SERVER'] = 'fantastopia.com'  # Your SMTP server
    app.config['MAIL_PORT'] = 587  # Port for SMTP (usually 587 for TLS)
    app.config['MAIL_USE_TLS'] = True  # Enable TLS
    app.config['MAIL_USERNAME'] = 'info@fantastopia.com'  # Your email username
    app.config['MAIL_PASSWORD'] = '~SL9{-^N-R8j'  # Your email password
    app.config['MAIL_DEFAULT_SENDER'] = 'info@fantastopia.com'  # Your default sender email
    
    mail.init_app(app)

    # Register blueprints
    from .auth import auth_bp
    from .guardians import guardians_bp
    from .alerts import alerts_bp

    app.register_blueprint(auth_bp)
    app.register_blueprint(guardians_bp)
    app.register_blueprint(alerts_bp)

    return app